with events_base as (

    select * 
    from {{ ref('stg_ga4_export__event') }}

),

events_report as (
    
    select
        event_date as date,
        null as property,
        fivetran_synced,
        event_name,
        count(unique_event_id) as event_count,
        avg(count(unique_event_id) / count(distinct user_id)) as event_count_per_user,
        sum(ecommerce_purchase_revenue_usd) as total_revenue,
        count(distinct user_id) as total_users

    from events_base
    group by 1, 2, 3, 4

)

select *
from events_report
