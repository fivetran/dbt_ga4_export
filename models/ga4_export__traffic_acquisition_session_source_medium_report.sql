-- traffic_acquisition_session_source_medium_report

with events_sessionized as (

    select * 
    from {{ ref('int_ga4_export__sessionized_events') }}

),

traffic_acquisition_report as (
    
    select
        event_date as date,
        null as property,
        fivetran_synced,
        traffic_source_medium as session_medium,
        traffic_source_source as session_source,
        count(distinct case when event_name = 'user_engagement' then session_id end) as engaged_sessions,
        count(distinct session_id) as total_sessions,
        count(distinct case when event_name = 'user_engagement' then session_id end)/ count(distinct session_id) as engagement_rate_comparison,
        avg(case when event_name = 'user_engagement' then 1 else 0 end) as engagement_rate,
        count(unique_event_id) as event_count,
        (count(unique_event_id)) / count(distinct session_id) as events_per_session,
        count(distinct case when event_name in ({{ "'" ~ var('conversion_events') | join("', '") ~ "'" }}) then unique_event_id end) as key_events,
        sum(ecommerce_purchase_revenue) as total_revenue,
        count(distinct user_id) as total_users,
        sum(case when event_name = 'user_engagement' then param_engagement_time_msec / 1000 end)/ count(distinct user_id) as user_engagement_duration

    from events_sessionized
    group by 1, 2, 3, 4, 5

)

select *
from traffic_acquisition_report
