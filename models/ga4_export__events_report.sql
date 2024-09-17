with events_base as (

    select * 
    from {{ ref('stg_ga4_export__event') }}

),

events_report as (
    
    select
        event_date,
        null as property,
        fivetran_synced,
        event_name,
        count(unique_event_id) as event_count,
        (count(unique_event_id) / nullif(count(distinct user_id),0)) as event_count_per_user,
        sum(ecommerce_purchase_revenue) as total_revenue,
        count(distinct user_pseudo_id) as total_users

    from events_base
    group by 1, 2, 3, 4

)

select *
from events_report
