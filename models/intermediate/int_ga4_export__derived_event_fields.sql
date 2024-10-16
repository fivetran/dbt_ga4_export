{{
    config(
        materialized='incremental' if ga4_export.is_incremental_compatible() else 'table',
        unique_key='event_id',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={"field": "event_date", "data_type": "date"} if target.type not in ('spark','databricks') else ['event_date'],
        cluster_by=['event_name'],
        file_format='delta'
    )
}}

with event_base as (
    select *
    from {{ ref('stg_ga4_export__event') }}

    {% if is_incremental() %}
    where event_date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=7, datepart='day') }}

    {% else %}
    -- Initial load or full refresh
    where event_date >= {{ "'" ~ var('ga4_export_date_start',  '2024-01-01') ~ "'" }}
    {% endif %}

), lagged_events as (

    select 
        *,
        lag(event_timestamp) over (partition by user_pseudo_id, platform, source_relation order by event_timestamp) as previous_event_timestamp

    from event_base

), derived_events as (

    select
        *,
        -- Only calculate for 'user_engagement' events
        case when event_name = 'user_engagement' and lag(event_timestamp) over (partition by user_pseudo_id, source_relation order by event_timestamp) is not null 
            then {{ dbt.datediff('previous_event_timestamp', 'event_timestamp', 'second') }} * 1000 -- Convert to milliseconds
            else null
        end as derived_engagement_time_msec,

        -- Create boolean for whether event is user_engagement to use in next CTE for deriving engaged_session
        cast(case when event_name = 'user_engagement' 
            then 1 
            else 0
        end as boolean) as derived_is_engaged_event,

        -- Generate session index based on 30-minute inactivity
        sum(case when {{ dbt.datediff('previous_event_timestamp', 'event_timestamp', 'minute')}} > 30 or previous_event_timestamp is null -- check time difference in minutes
            then 1 
            else 0 
        end) over (partition by user_pseudo_id, platform, source_relation order by event_timestamp rows between unbounded preceding and current row) as derived_session_index

    from lagged_events

), final_sessionized as (

    select
        *,
        -- Coalesce param_engagement_time_msec or use the derived_engagement_time_msec as engagement_time in milliseconds
        coalesce(param_engagement_time_msec,derived_engagement_time_msec) as engagement_time_msec,
        -- Coalesce param_session_engaged or use the derived_is_engaged_event as is_session_engaged
        cast(coalesce(param_session_engaged,derived_is_engaged_event) as boolean) as is_session_engaged,
        -- Coalesce param_ga_session_number or use the derived_session_index as the session_number
        cast(coalesce(param_ga_session_number, derived_session_index) as {{ dbt.type_string() }}) as session_number

    from derived_events

)

select
    *,
    -- Concat the user_id with either the param_ga_session_id or derived session_number to generate session_id
    {{ dbt.concat(["user_pseudo_id", "'_'", "coalesce(param_ga_session_id, session_number)"]) }} as session_id
from final_sessionized