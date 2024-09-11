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
        -- Generate session index based on 30-minute inactivity
        sum(
            case 
                -- Use TIMESTAMP_DIFF to check time difference in minutes
                when TIMESTAMP_DIFF(event_timestamp, previous_event_timestamp, MINUTE) > 30 
                    or previous_event_timestamp is null
                then 1 
                else 0 
            end
        ) over (partition by user_pseudo_id, platform order by event_timestamp) as session_index

    from lagged_events

), final_sessionized as (
    select
        se.*,
        -- Coalesce param_ga_session_id or create session_id from session_index
        coalesce(se.param_ga_session_id, concat(se.user_pseudo_id, '_', se.platform, '_', se.session_index)) as session_id
    from sessionized_events se
),

sessions_aggregate as (
    -- Aggregate session-level data
    select
        session_id,
        min(event_timestamp) as session_start_time,
        max(event_timestamp) as session_end_time,
        sum(param_engagement_time_msec) / 1000 as total_session_engagement_time_sec,
        count(distinct event_name) as total_events,
        max(case when param_session_engaged = 1 then 1 else 0 end) as engaged_session
    from final_sessionized
    group by session_id
)

select *
from sessions_aggregate
order by session_start_time