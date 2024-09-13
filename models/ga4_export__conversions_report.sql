with events_base as (

    select * 
    from {{ ref('stg_ga4_export__event') }}
    where event_name in ({{ "'" ~ var('conversion_events') | join("', '") ~ "'" }})

),

conversions_report as (
    
    select
        event_date,
        null as property,
        fivetran_synced,
        event_name,
        count(distinct unique_event_id) as key_events,
        sum(ecommerce_purchase_revenue) as total_revenue,
        count(distinct user_id) as total_users

    from events_base
    group by 1, 2, 3, 4

)

select *
from conversions_report
