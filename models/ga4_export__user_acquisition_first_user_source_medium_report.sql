with events_base as (

    select * 
    from {{ ref('stg_google_analytics_4_event') }}

),

user_acquisition_report as (
    
    select 
        _fivetran_id,
        event_date as date,
        property,
        _fivetran_synced,
        count(distinct case when user_first_touch_timestamp is not null then user_id end) as new_users,
        sum(engaged_sessions) as engaged_sessions,
        avg(engagement_rate) as engagement_rate,
        count(*) as event_count,
        first_user_medium as first_user_medium,
        first_user_source as first_user_source,
        count(distinct case when name in ('purchase', 'sign_up') then user_id end) as key_events,
        sum(ecommerce_purchase_revenue_usd) as total_revenue,
        count(distinct user_id) as total_users,
        sum(user_engagement_duration) as user_engagement_duration

    from events_base
    group by 1, 2, 3, 4, 5, 6

)

select *
from user_acquisition_report
