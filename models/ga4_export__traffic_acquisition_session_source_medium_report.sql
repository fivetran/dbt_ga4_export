-- traffic_acquisition_session_source_medium_report
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
        cluster_by=['event_date', 'session_medium', 'session_source'],
        file_format='delta'
    )
}}

with derived_event_fields as (

    select * 
    from {{ ref('int_ga4_export__derived_event_fields') }}
    -- made incremental upstream

    {% if is_incremental() %}
    where event_date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=7, datepart='day') }}
    {% endif %}

),

traffic_acquisition_report as (
    
    select
        event_date,
        source_relation,
        traffic_source_medium as session_medium,
        traffic_source_source as session_source,
        count(distinct case when event_name = 'user_engagement' then session_id end) as engaged_sessions,
        count(distinct session_id) as total_sessions,
        round(count(distinct case when event_name = 'user_engagement' then session_id end)/ nullif(count(distinct session_id),0) ,2) as engagement_rate_comparison,
        count(unique_event_id) as event_count,
        round((count(unique_event_id)) / nullif(count(distinct session_id),0), 2) as events_per_session,
        count(distinct case when event_name in ({{ "'" ~ var('key_events') | join("', '") ~ "'" }}) then unique_event_id end) as key_events,
        sum(ecommerce_purchase_revenue) as total_revenue,
        count(distinct user_pseudo_id) as total_users,
        round(sum(case when event_name = 'user_engagement' then engagement_time_msec / 1000 end)/ nullif(count(distinct user_id),0), 2) as user_engagement_duration

    from derived_event_fields
    group by 1, 2, 3, 4

)

select 
    *,
    {{ dbt_utils.generate_surrogate_key(['event_date', 'session_medium', 'session_source', 'source_relation']) }} as unique_key
from traffic_acquisition_report
