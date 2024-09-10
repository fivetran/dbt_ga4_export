with events_base as (

    select * 
    from {{ ref('stg_google_analytics_4_event') }}
    where event_name in var('conversion_events')

),

conversions_report as (
    
    select 
        _fivetran_id,
        event_date as date,
        property, -- where to get...
        _fivetran_synced,
        event_name as event_name,
        count(distinct user_id end) as key_events,
        sum(ecommerce_purchase_revenue_usd) as total_revenue,
        count(distinct user_id) as total_users

    from events_base
    group by 1, 2, 3, 4, 5, 6

)

select *
from conversions_report
