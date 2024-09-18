{% macro get_event_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "bundle_sequence_id", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_string(), "alias": "event_date"},
    {"name": "device_category", "datatype": dbt.type_string()},
    {"name": "geo_city", "datatype": dbt.type_string()},
    {"name": "geo_country", "datatype": dbt.type_string()},
    {"name": "geo_region", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string(), "alias": "event_name"},
    {"name": "platform", "datatype": dbt.type_string()},
    {"name": "timestamp", "datatype": dbt.type_timestamp(), "alias": "event_timestamp"},
    {"name": "traffic_source_medium", "datatype": dbt.type_string()},
    {"name": "traffic_source_name", "datatype": dbt.type_string()},
    {"name": "traffic_source_source", "datatype": dbt.type_string()},
    {"name": "user_first_touch_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "user_id", "datatype": dbt.type_string()},
    {"name": "user_pseudo_id", "datatype": dbt.type_string()},
    {"name": "value_in_usd", "datatype": dbt.type_float()},
    {"name": "ecommerce_purchase_revenue_in_usd", "datatype": dbt.type_float()},
    {"name": "ecommerce_refund_value_in_usd", "datatype": dbt.type_float()},
    {"name": "ecommerce_purchase_revenue", "datatype": dbt.type_float()},
    {"name": "ecommerce_refund_value", "datatype": dbt.type_float()},
    {"name": "ecommerce_total_item_quantity", "datatype": dbt.type_int()},
    {"name": "ecommerce_transaction_id", "datatype": dbt.type_string()},
    {"name": "event_dimensions_hostname", "datatype": dbt.type_string()},
    {"name": "param_video_duration", "datatype": dbt.type_int()},
    {"name": "param_percent_scrolled", "datatype": dbt.type_float()},
    {"name": "param_campaign", "datatype": dbt.type_string()},
    {"name": "param_gclid", "datatype": dbt.type_string()},
    {"name": "param_medium", "datatype": dbt.type_string()},
    {"name": "param_source", "datatype": dbt.type_string()},
    {"name": "param_ga_session_id", "datatype": dbt.type_string()},
    {"name": "param_ga_session_number", "datatype": dbt.type_float()},
    {"name": "param_engagement_time_msec", "datatype": dbt.type_float()},
    {"name": "param_engaged_session_event", "datatype": dbt.type_string()},
    {"name": "param_session_engaged", "datatype": "boolean"},
    {"name": "is_intraday", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
