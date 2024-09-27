{{
    config(
        materialized='incremental' if ga4_export.is_incremental_compatible() else 'table',
        unique_key='unique_key',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={
            "field": "event_date", 
            "data_type": "date"
            } if target.type not in ('spark','databricks') 
            else ['event_date'],
        cluster_by=['event_name', 'event_date'],
        file_format='delta'
    )
}}

with event_base as (
    select *
    from {{ ref('stg_ga4_export__event') }}

    {% if is_incremental() %}
    where event_date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=7, datepart='day') }}
    {% endif %}

), lagged_events as (

    select 
        *,
        lag(event_timestamp) over (partition by user_pseudo_id, platform order by event_timestamp) as previous_event_timestamp

    from event_base

), sessionized_events as (

    select
        *,
        -- Only calculate for 'user_engagement' events
        case 
            when event_name = 'user_engagement' 
                and lag(event_timestamp) over (partition by user_pseudo_id order by event_timestamp) is not null 
            then 
                {{ dbt.datediff('previous_event_timestamp', 'event_timestamp', 'second') }} * 1000 -- Convert to milliseconds
            else null
        end as derived_engagement_time_msec,

        -- Create boolean for whether event is user_engagement to use in next CTE for deriving engaged_session
        case
            when event_name = 'user_engagement' 
            then 1 else 0
        end as is_engaged_event,

        -- Generate session index based on 30-minute inactivity
        sum(
            case 
                -- check time difference in minutes
                when {{ dbt.datediff('previous_event_timestamp', 'event_timestamp', 'minute')}} > 30 
                    or previous_event_timestamp is null
                then 1 
                else 0 
            end
        ) over (partition by user_pseudo_id, platform order by event_timestamp) as session_index

    from lagged_events

), final_sessionized as (

    select
        *,
        -- Coalesce param_engagement_time_msec or use the derived_engagement_time_msec as engagement_time in milliseconds
        coalesce(param_engagement_time_msec,derived_engagement_time_msec) as engagement_time_msec,
        coalesce(param_session_engaged,is_engaged_event) as is_session_engaged,
        -- Coalesce param_ga_session_id or create session_id from session_index
        concat(user_pseudo_id, '_', coalesce(param_ga_session_id, concat(platform, '_', session_index)) ) as session_id -- user_pseudo_id and session_id

    from sessionized_events se

)

select *
from final_sessionized