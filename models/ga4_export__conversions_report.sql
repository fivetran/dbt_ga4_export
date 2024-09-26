{{
    config(
        materialized='incremental' if ga4_export.is_incremental_compatible() else 'table',
        unique_key='unique_key',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={
            "field": "event_date", 
            "data_type": "date"
            } if target.type not in ('spark','databricks') 
            else ['event_date'],
        cluster_by=['event_name', 'event_date'],
        file_format='delta'
    )
}}

with events_base as (

    select * 
    from {{ ref('stg_ga4_export__event') }}
    where event_name in ({{ "'" ~ var('key_events') | join("', '") ~ "'" }})

    {% if is_incremental() %}
    and event_date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=7, datepart='day') }}
    {% endif %}

),

conversions_report as (
    
    select
        event_date,
        event_name,
        source_relation,
        count(event_id) as key_events,
        sum(ecommerce_purchase_revenue) as total_revenue,
        count(distinct user_pseudo_id) as total_users

    from events_base
    group by 1, 2, 3

)

select
    *,
    {{ dbt_utils.generate_surrogate_key(['event_date', 'event_name', 'source_relation']) }} as unique_key
from conversions_report
