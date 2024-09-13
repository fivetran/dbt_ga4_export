with derived_event_fields as (
    select *
    from {{ ref('int_ga4_export__derived_event_fields') }}
),

sessions_aggregate as (
    -- Aggregate session-level data
    select
        session_id,
        min(event_timestamp) as session_start_time,
        max(event_timestamp) as session_end_time,
        sum(param_engagement_time_msec) / 1000 as total_session_engagement_time_sec,
        count(distinct event_name) as total_events,
        max(case when param_session_engaged = 1 then 1 else 0 end) as engaged_session -- maybe instead use event_name = 'user_engagement'
    from derived_event_fields
    group by session_id
)

select *
from sessions_aggregate
order by session_start_time