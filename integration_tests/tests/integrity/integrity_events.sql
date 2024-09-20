{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with events as (

    select 
        count(unique_event_id) as total_events
    from {{ ref('stg_ga4_export__event') }}
),

event_reports as (

    select
        sum(event_count) as total_events
    from {{ ref('ga4_export__events_report') }}
),

session_report as (

    select
        sum(event_count) as total_events
    from {{ ref('ga4_export__traffic_acquisition_session_source_medium_report') }}
),

user_report as (

    select
        sum(event_count) as total_events
    from {{ ref('ga4_export__user_acquisition_first_user_source_medium_report') }}
)

select 
    events.total_events as stg_total_events,
    event_reports.total_events as events_report_total_events,
    session_report.total_events as session_report_total_events,
    user_report.total_events as user_report_total_events
from 
    events, event_reports, session_report, user_report
where 
    events.total_events != event_reports.total_events 
    or events.total_events != session_report.total_events
    or events.total_events != user_report.total_events
    or event_reports.total_events != session_report.total_events
    or event_reports.total_events != user_report.total_events
    or session_report.total_events != user_report.total_events