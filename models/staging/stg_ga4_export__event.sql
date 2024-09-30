{{
    config(
        materialized='incremental' if ga4_export.is_incremental_compatible() else 'table',
        unique_key='event_id',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={
            "field": "event_date", 
            "data_type": "date"
            } if target.type not in ('spark','databricks') 
            else ['event_date'],
        cluster_by=['event_name', 'event_date', 'bundle_sequence_id'],
        file_format='delta'
    )
}}

with base as (

    select * 
    from {{ ref('stg_ga4_export__event_base') }}

    {% if is_incremental() %}
    where date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=7, datepart='day') }}
    {% else %}
    -- Initial load or full refresh
    where date >= {{ "'" ~ var('ga4_export_date_start',  '2024-01-01') ~ "'" }}
    {% endif %}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_ga4_export__event_base')),
                staging_columns=get_event_columns()
            )
        }}
        -- Using source relation to account for different union schemas and databases if needed
        {{ fivetran_utils.source_relation(
            union_schema_variable='ga4_export_union_schemas', 
            union_database_variable='ga4_export_union_databases')
        }}
    from base

),

final_pre as (
    
    select
        cast(_fivetran_id as {{ dbt.type_string() }}) as fivetran_id,
        concat(user_pseudo_id, '_', event_timestamp, '_', event_name, '_', bundle_sequence_id) as event_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as fivetran_synced,
        cast(bundle_sequence_id as {{ dbt.type_string() }}) as bundle_sequence_id,
        event_date, -- renamed in macro due to reserved word
        device_category,
        geo_city,
        geo_country,
        geo_region,
        event_name, -- renamed in macro due to reserved word
        platform,
        cast(event_timestamp as {{ dbt.type_timestamp() }}) as event_timestamp, -- renamed in macro due to reserved word
        coalesce(collected_traffic_source_manual_medium,traffic_source_medium, param_medium) as source_medium,
        coalesce(collected_traffic_source_manual_source,traffic_source_source, param_source) as source_source,
        cast(user_first_touch_timestamp as {{ dbt.type_timestamp() }}) as user_first_touch_timestamp,
        cast(user_id as {{ dbt.type_string() }}) as user_id,
        cast(user_pseudo_id as {{ dbt.type_string() }}) as user_pseudo_id,
        cast(value_in_usd as {{ dbt.type_float() }}) as event_value_usd,
        cast(ecommerce_purchase_revenue_in_usd as {{ dbt.type_float() }}) as ecommerce_purchase_revenue_usd,
        cast(ecommerce_purchase_revenue as {{ dbt.type_float() }}) as ecommerce_purchase_revenue,
        cast(ecommerce_refund_value_in_usd as {{ dbt.type_float() }}) as ecommerce_refund_value_usd,
        cast(ecommerce_refund_value as {{ dbt.type_float() }}) as ecommerce_refund_value,
        cast(ecommerce_total_item_quantity as {{ dbt.type_float() }}) as ecommerce_total_item_quantity,
        cast(ecommerce_transaction_id as {{ dbt.type_string() }}) as ecommerce_transaction_id,
        event_dimensions_hostname,
        cast(param_video_duration as {{ dbt.type_float() }}) as param_video_duration,
        cast(param_percent_scrolled as {{ dbt.type_float() }}) as param_percent_scrolled,
        param_campaign as param_campaign,
        cast(param_gclid as {{ dbt.type_string() }}) as param_gclid,
        param_medium,
        param_source,
        cast(param_ga_session_id as {{ dbt.type_string() }}) as param_ga_session_id,
        param_ga_session_number,
        cast(param_engagement_time_msec as {{ dbt.type_float() }}) as param_engagement_time_msec,
        param_engaged_session_event,
        param_session_engaged,
        cast(stream_id as {{ dbt.type_string() }}) as stream_id,
        is_intraday,
        source_relation

    from fields

),

exclude_intraday as (

    select
        *
    from final_pre
    where is_intraday = false

)

select
    *
from exclude_intraday
