with base as (

    select * 
    from {{ ref('stg_ga4_export__event_base') }}

    where date = '2024-05-10'
    -- order by user_pseudo_id -- tmp order
    -- where 

    -- {% if is_incremental() %}
    -- event_date >= {{ ga4_export.ga4_export_lookback(from_date="max(event_date)", interval=var('lookback_window', 7), datepart='day') }}

    -- {% else %}
    -- -- limit date range on the first run / refresh
    -- event_date >= {{ "'" ~ var('ga4_export_date_start',  '2024-01-01') ~ "'" }} 
    -- {% endif %}

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

final as (
    
    select
        cast(_fivetran_id as {{ dbt.type_string() }}) as unique_event_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as fivetran_synced,
        cast(bundle_sequence_id as {{ dbt.type_int() }}) as bundle_sequence_id,
        event_date, -- renamed in macro due to reserved word
        device_category,
        geo_city,
        geo_country,
        geo_region,
        event_name, -- renamed in macro due to reserved word
        platform,
        cast(timestamp as {{ dbt.type_timestamp() }}) as event_timestamp,
        traffic_source_medium,
        traffic_source_name,
        traffic_source_source,
        cast(user_first_touch_timestamp as {{ dbt.type_timestamp() }}) as user_first_touch_timestamp,
        cast(user_id as {{ dbt.type_string() }}) as user_id,
        cast(user_pseudo_id as {{ dbt.type_string() }}) as user_pseudo_id,
        cast(value_in_usd as {{ dbt.type_float() }}) as event_value_usd,
        cast(ecommerce_purchase_revenue_in_usd as {{ dbt.type_float() }}) as ecommerce_purchase_revenue_usd,
        cast(ecommerce_purchase_revenue as {{ dbt.type_float() }}) as ecommerce_purchase_revenue,
        cast(ecommerce_refund_value_in_usd as {{ dbt.type_float() }}) as ecommerce_refund_value_usd,
        cast(ecommerce_refund_value as {{ dbt.type_float() }}) as ecommerce_refund_value,
        cast(ecommerce_total_item_quantity as {{ dbt.type_int() }}) as ecommerce_total_item_quantity,
        cast(ecommerce_transaction_id as {{ dbt.type_string() }}) as ecommerce_transaction_id,
        event_dimensions_hostname,
        cast(param_video_duration as {{ dbt.type_int() }}) as video_duration,
        cast(param_percent_scrolled as {{ dbt.type_float() }}) as percent_scrolled,
        param_campaign as campaign,
        cast(param_gclid as {{ dbt.type_string() }}) as gclid,
        param_medium as medium, -- need to check if param_ fields are custom and therefore we can't use them
        param_source as source,
        cast(param_ga_session_id as {{ dbt.type_string() }}) as param_ga_session_id, -- maybe we don't use this and instead bring in ga_session_id from event_param
        param_ga_session_number,
        param_engagement_time_msec,
        param_engaged_session_event,
        param_session_engaged,
        is_intraday,
        source_relation

    from fields

)

select *
from final
