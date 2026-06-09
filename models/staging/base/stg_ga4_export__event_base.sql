{% if var('ga4_export_union_schemas', []) | length > 0 or var('ga4_export_union_databases', []) | length > 0 %}

{{
    fivetran_utils.union_data(
        table_identifier='event',
        database_variable='ga4_export_database',
        schema_variable='ga4_export_schema',
        default_database=target.database,
        default_schema='ga4_export',
        default_variable='event',
        union_schema_variable='ga4_export_union_schemas',
        union_database_variable='ga4_export_union_databases'
    )
}}

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='ga4_export_sources',
        single_source_name='ga4_export',
        single_table_name='event'
    )
}}

{% endif %}
