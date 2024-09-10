with base as (

    select * 
    from {{ ref('stg_ga4_export__event_base') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('raw_ga4_export_4_export__event')),
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
        cast(_fivetran_id as {{ dbt.type_string() }}) as fivetran_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as fivetran_synced,
        cast(bundle_sequence_id as {{ dbt.type_int() }}) as bundle_sequence_id,
        cast(date as {{ dbt.type_string() }}) as event_date,
        device_category,
        geo_city,
        geo_country,
        geo_region,
        name as event_name,
        platform,
        cast(timestamp as {{ dbt.type_timestamp() }}) as event_timestamp,
        traffic_source_medium,
        traffic_source_name,
        traffic_source_source,
        cast(user_first_touch_timestamp as {{ dbt.type_timestamp() }}) as user_first_touch_timestamp,
        user_id,
        user_pseudo_id,
        cast(value_in_usd as {{ dbt.type_float() }}) as event_value_usd,
        cast(ecommerce_purchase_revenue_in_usd as {{ dbt.type_float() }}) as ecommerce_purchase_revenue_usd,
        cast(ecommerce_refund_value_in_usd as {{ dbt.type_float() }}) as ecommerce_refund_value_usd,
        cast(ecommerce_total_item_quantity as {{ dbt.type_int() }}) as ecommerce_total_item_quantity,
        ecommerce_transaction_id,
        event_dimensions_hostname,
        cast(param_video_duration as {{ dbt.type_int() }}) as video_duration,
        cast(param_percent_scrolled as {{ dbt.type_float() }}) as percent_scrolled,
        param_campaign as campaign,
        param_gclid as gclid,
        param_medium as medium,
        param_source as source,
        source_relation

    from fields

)

select *
from final
