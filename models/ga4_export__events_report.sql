{{
    config(
        materialized='incremental' if ga4_export.is_incremental_compatible() else 'table',
        unique_key='unique_key',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={"field": "event_date", "data_type": "date"} if target.type not in ('spark','databricks') else ['event_date'],
        cluster_by=['event_name'],
        file_format='delta'
    )
}}

with events_base as (

    select * 
    from {{ ref('stg_ga4_export__event') }}

    {% if is_incremental() %}
    where event_date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=7, datepart='day') }}

    {% else %}
    -- Initial load or full refresh
    where event_date >= {{ "'" ~ var('ga4_export_date_start',  '2024-01-01') ~ "'" }}
    {% endif %}

),

events_report as (
    
    select
        event_date,
        event_name,
        source_relation,
        count(event_id) as event_count,
        round((count(event_id) / nullif(count(distinct user_pseudo_id),0)) ,2) as event_count_per_user,
        coalesce(sum(ecommerce_purchase_revenue),0) as total_revenue,
        count(distinct user_pseudo_id) as total_users

    from events_base
    group by 1, 2, 3

)

select
    *,
    {{ dbt_utils.generate_surrogate_key(['event_date', 'event_name', 'source_relation']) }} as unique_key
from events_report
