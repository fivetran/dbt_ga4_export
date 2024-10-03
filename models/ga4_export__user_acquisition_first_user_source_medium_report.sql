-- user_acquisition_first_user_source_medium_report
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
        cluster_by=['event_date', 'first_user_medium', 'first_user_source'],
        file_format='delta'
    )
}}

with derived_event_fields as (

    select *
    from {{ ref('int_ga4_export__derived_event_fields') }}
        -- made incremental upstream

    {% if is_incremental() %}
    where event_date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=7, datepart='day') }}

    {% else %}
    -- Initial load or full refresh
    where event_date >= {{ "'" ~ var('ga4_export_date_start',  '2024-01-01') ~ "'" }}
    {% endif %}

), user_first_event as (

    select *
    from {{ ref('int_ga4_export__user_first_event') }}

), user_acquisition_report as (
    
    select
        event_date,
        source_relation,
        user_first_event.first_user_medium,
        user_first_event.first_user_source,
        count(distinct case when is_session_engaged then session_id end) as engaged_sessions,
        round(cast(count(distinct case when is_session_engaged then session_id end)/ nullif(count(distinct session_id),0) as {{ dbt.type_numeric() }} ),2) as engagement_rate,
        count(event_id) as event_count,
        count(case when event_name in ({{ "'" ~ var('key_events') | join("', '") ~ "'" }}) then event_id end) as key_events, -- stipulate the names of your key events in your dbt_project.yml.
        count(distinct case when event_name = 'first_visit' then derived_event_fields.user_pseudo_id end) as new_users,
        count(distinct derived_event_fields.user_pseudo_id) as total_users,
        coalesce(sum(ecommerce_purchase_revenue),0) as total_revenue,
        round(cast(sum(case when is_session_engaged then engagement_time_msec else 0 end)/ nullif(count(distinct session_id),0) as {{ dbt.type_numeric() }}), 2) as user_engagement_duration


    from derived_event_fields
    left join user_first_event
        on derived_event_fields.user_pseudo_id = user_first_event.user_pseudo_id

    group by 1, 2, 3, 4

)

select
    *,
    {{ dbt_utils.generate_surrogate_key(['event_date', 'first_user_medium', 'first_user_source', 'source_relation']) }} as unique_key
from user_acquisition_report
