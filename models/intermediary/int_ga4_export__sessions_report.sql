{{
    config(
        materialized='incremental' if ga4_export.is_incremental_compatible() else 'table',
        unique_key='session_id',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={
            "field": "session_start_time",
            "data_type": "timestamp"
            } if target.type not in ('spark', 'databricks') 
            else ['session_start_time'],
        cluster_by=['session_id', 'session_start_time'],
        file_format='delta'
    )
}}

with derived_event_fields as (
    select *
    from {{ ref('int_ga4_export__derived_event_fields') }}
),

sessions_aggregate as (
    -- Aggregate session-level data
    select
        session_id,
        min(event_timestamp) as session_start_time,
        max(event_timestamp) as session_end_time,
        sum(engagement_time_msec) / 1000 as total_session_engagement_time_sec,
        count(event_id) as total_events,
        max(case when is_session_engaged then 1 else 0 end) as is_engaged_session
    from derived_event_fields
    group by session_id
)

select *
from sessions_aggregate