with events_base as (

    select * 
    from {{ ref('stg_google_analytics_4_event') }}

),

events_report as (
    
    select 
        _fivetran_id,
        event_date as date,
        property,
        _fivetran_synced,
        count(*) as event_count,
        avg(event_count / count(distinct user_id)) as event_count_per_user,
        event_name as event_name,
        sum(ecommerce_purchase_revenue_usd) as total_revenue,
        count(distinct user_id) as total_users

    from events_base
    group by 1, 2, 3, 4, 5, 6

)

select *
from events_report
