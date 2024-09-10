
with base as (

    select * 
    from {{ ref('stg_ga4_export__event_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_ga4_export__event_base')),
                staging_columns=get_core_company_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='ga4_union_schemas', 
            union_database_variable='ga4_union_databases') 
        }}
    from base
),

final as (
    
    select 
        event_bundle_sequence_id,
        event_name,
        event_timestamp,
        event_previous_timestamp,
        event_value_in_usd,
        event_bundle_sequence_id,
        user_id as user_pseudo_id,
        user_first_touch_timestamp,
        device_category,
        geo_country,
        geo_region,
        geo_city,
        traffic_source_medium,
        traffic_source_source,
        traffic_source_name,
        traffic_source_campaign,
        platform,
        event_params,
        event_count,
        session_start_timestamp,
        session_id,
        user_engagement as engagement_time_msec,
        conversion_value,
        total_users,
        total_revenue,
        new_users,
        engaged_sessions,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('ga4_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

        {{ fivetran_utils.fill_pass_through_columns('event_pass_through_columns') }}

    from fields

)

select * 
from final