with event_base as (
    select *
    from {{ ref('stg_ga4_export__event') }}

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

        -- Generate session index based on 30-minute inactivity
        sum(
            case 
                -- Use TIMESTAMP_DIFF to check time difference in minutes
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
        
        -- Coalesce param_ga_session_id or create session_id from session_index
        coalesce(se.param_ga_session_id, concat(se.user_pseudo_id, '_', se.platform, '_', se.session_index)) as session_id
    from sessionized_events se

)

select * 
from final_sessionized