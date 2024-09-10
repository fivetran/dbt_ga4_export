with events_base as (

    select * 
    from {{ ref('stg_google_analytics_4_event') }}

),

traffic_acquisition_report as (
    
    select 
        _fivetran_id,
        event_date as date,
        property,
        _fivetran_synced,
        sum(engaged_sessions) as engaged_sessions,
        avg(engagement_rate) as engagement_rate,
        count(*) as event_count,
        avg(event_count / sessions) as events_per_session,
        count(distinct case when name in var('conversion_events') then user_id end) as key_events,
        session_medium as session_medium,
        session_source as session_source,
        count(distinct session_id) as sessions,
        sum(ecommerce_purchase_revenue_usd) as total_revenue,
        count(distinct user_id) as total_users,
        sum(user_engagement_duration) as user_engagement_duration

    from events_base
    group by 1, 2, 3, 4, 5, 6

)

select *
from traffic_acquisition_report
