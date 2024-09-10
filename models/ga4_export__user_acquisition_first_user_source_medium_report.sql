with events_base as (

    select * 
    from {{ ref('stg_ga4_export__event') }}

),

user_acquisition_report as (
    
    select
        event_date as date,
        null as property,
        fivetran_synced,
        first_user_medium as first_user_medium,
        first_user_source as first_user_source,
        sum(engaged_sessions) as engaged_sessions,
        avg(case when event_name = 'user_engagement' then 1 else 0 end) as engagement_rate,
        count(unique_event_id) as event_count,
        count(distinct case when name in ({{ "'" ~ var('conversion_events') | join("', '") ~ "'" }}) then unique_event_id end) as key_events,
        count(distinct case when user_first_touch_timestamp is not null then user_id end) as new_users,
        count(distinct user_id) as total_users,
        sum(ecommerce_purchase_revenue_usd) as total_revenue,
        avg(user_engagement_duration) as user_engagement_duration

    from events_base
    group by 1, 2, 3, 4, 5

)

select *
from user_acquisition_report
