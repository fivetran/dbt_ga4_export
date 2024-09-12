-- user_source_medium_report

with events_sessionized as (

    select * 
    from {{ ref('int_ga4_export__sessionized_events') }}

), user_first_event as (

    select *
    from {{ ref('int_ga4_export__user_first_event') }}

), user_acquisition_report as (
    
    select
        event_date as date,
        null as property,
        fivetran_synced,
        user_first_event.first_user_medium as first_user_medium,
        user_first_event.first_user_source as first_user_source,
        count(distinct case when event_name = 'user_engagement' then session_id end) as engaged_sessions,
        avg(case when event_name = 'user_engagement' then 1 else 0 end) as engagement_rate,
        count(unique_event_id) as event_count,
        count(distinct case when event_name in ({{ "'" ~ var('conversion_events') | join("', '") ~ "'" }}) then unique_event_id end) as key_events,
        count(distinct case when user_first_touch_timestamp is not null then user_id end) as new_users,
        count(distinct user_id) as total_users,
        sum(ecommerce_purchase_revenue) as total_revenue,
        sum(case when event_name = 'user_engagement' then param_engagement_time_msec / 1000 end)/ nullif(count(distinct user_id),0) as user_engagement_duration

    from events_sessionized
    left join user_first_event
        on events_sessionized.user_pseudo_id = user_first_event.user_pseudo_id

    group by 1, 2, 3, 4, 5

)

select *
from user_acquisition_report
