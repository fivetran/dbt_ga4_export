{% macro get_event_columns() %}

{% set columns = [

    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "event_bundle_sequence_id", "datatype": dbt.type_int()},
    {"name": "event_name", "datatype": dbt.type_string()},
    {"name": "event_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "event_previous_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "event_value_in_usd", "datatype": dbt.type_float()},
    {"name": "user_id", "datatype": dbt.type_string()},
    {"name": "user_first_touch_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "device_category", "datatype": dbt.type_string()},
    {"name": "geo_country", "datatype": dbt.type_string()},
    {"name": "geo_region", "datatype": dbt.type_string()},
    {"name": "geo_city", "datatype": dbt.type_string()},
    {"name": "traffic_source_medium", "datatype": dbt.type_string()},
    {"name": "traffic_source_source", "datatype": dbt.type_string()},
    {"name": "traffic_source_name", "datatype": dbt.type_string()},
    {"name": "traffic_source_campaign", "datatype": dbt.type_string()},
    {"name": "platform", "datatype": dbt.type_string()},
    {"name": "event_params", "datatype": dbt.type_string()},
    {"name": "event_count", "datatype": dbt.type_int()},
    {"name": "session_start_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "session_id", "datatype": dbt.type_string()},
    {"name": "user_engagement", "datatype": dbt.type_int()},
    {"name": "conversion_value", "datatype": dbt.type_float()},
    {"name": "total_users", "datatype": dbt.type_int()},
    {"name": "total_revenue", "datatype": dbt.type_float()},
    {"name": "new_users", "datatype": dbt.type_int()},
    {"name": "engaged_sessions", "datatype": dbt.type_int()},
    {"name": "screen_width", "datatype": dbt.type_int()},
    {"name": "screen_height", "datatype": dbt.type_int()},
    {"name": "os_version", "datatype": dbt.type_string()},
    {"name": "app_version", "datatype": dbt.type_string()}

] %}

{{ return(columns) }}

{% endmacro %}
