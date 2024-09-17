-- user_source_medium_report

with derived_event_fields as (

    select * 
    from {{ ref('int_ga4_export__derived_event_fields') }}

), user_first_event as (

    select *
    from {{ ref('int_ga4_export__user_first_event') }}

), user_acquisition_report as (
    
    select
        event_date,
        null as property,
        fivetran_synced,
        user_first_event.first_user_medium as first_user_medium,
        user_first_event.first_user_source as first_user_source,
        count(distinct case when event_name = 'user_engagement' then session_id end) as engaged_sessions,
        avg(case when event_name = 'user_engagement' then 1 else 0 end) as engagement_rate,
        count(unique_event_id) as event_count,
        count(distinct case when event_name in ({{ "'" ~ var('key_events') | join("', '") ~ "'" }}) then unique_event_id end) as key_events,
        count(distinct case when user_first_touch_timestamp is not null then user_id end) as new_users,
        count(distinct user_pseudo_id) as total_users,
        sum(ecommerce_purchase_revenue) as total_revenue,
        round(sum(case when event_name = 'user_engagement' then engagement_time_msec / 1000 end)/ nullif(count(distinct user_id),0), 2) as user_engagement_duration

    from derived_event_fields
    left join user_first_event
        on derived_event_fields.user_pseudo_id = user_first_event.user_pseudo_id

    group by 1, 2, 3, 4, 5

)

select *
from user_acquisition_report
