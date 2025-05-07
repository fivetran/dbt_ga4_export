# dbt_ga4_export v0.2.0
[PR #7](https://github.com/fivetran/dbt_ga4_export/pull/7) includes the following changes:

## Breaking Change (`--full-refresh` required after upgrading) 
- Incorporates `batch_event_index` into the generated `event_id` field. This update affects the upstream `stg_ga4_export__event` model and requires a full refresh of the downstream `int_ga4_export__derived_event_fields` model, where `event_id` is used as the unique key in incremental logic.
- Resolved an issue where `event_id` was `null` in the `stg_ga4_export__event` model when user_pseudo_id was missing. This was fixed by using a coalesce to substitute empty strings during concatenation.

## Documentation
- Added Quickstart model counts to README. ([#5](https://github.com/fivetran/dbt_ga4_export/pull/5))
- Corrected references to connectors and connections in the README. ([#5](https://github.com/fivetran/dbt_ga4_export/pull/5))

# dbt_ga4_export v0.1.0 
This is the initial release of the GA4 Export dbt package!

## What does this dbt package do?
This package models GA4 Export data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/google-analytics-4-export). It uses data in the format described by [this ERD](https://fivetran.com/docs/connectors/applications/google-analytics-4-export#schemainformation).

The main focus of the package is to transform the source event table into commonly used GA4 reports. The package includes the following:
  - Materializes [GA4 Export staging and output models](https://fivetran.github.io/dbt_ga4_export/#!/overview/ga4_export_source/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/connectors/applications/google-analytics-4-export#schemainformation). 
  - The staging event table cleans, tests, and prepares your GA4 Export data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/google-analytics-4-export) by doing the following:
    - Renames fields for consistency and standardization. For example, `name` is renamed to `event_name`.
    - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
    - Generates a comprehensive data dictionary of your GA4 Export data through the [dbt docs site](https://fivetran.github.io/dbt_ga4_export/).
  - The following GA4 reports are reproduced in this package as titular tables:


| **Table** | **GA4 Report** | **Description**                                                                                                     |
|---------------------|---------------------|---------------------------------------------------------------------------------------------------------------------|
| [ga4_export__traffic_acquisition_ <br> session_source_medium_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__traffic_acquisition_session_source_medium_report) | [traffic_acquisition_session_ <br> source_medium_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#trafficacquisitionsessionsourcemediumreport) | Tracks metrics including sessions, events, users, and revenue <br> by source and medium. |
| [ga4_export__user_acquisition_ <br> first_user_source_medium_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__user_acquisition_first_user_source_medium_report) | [user_acquisition_ <br> first_user_source_medium_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#useracquisitionfirstusersourcemediumreport) | Tracks metrics including sessions, events, users, and revenue <br> by first user medium and source. |
| [ga4_export__events_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__events_report) | [events_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#eventsreport) | Summarizes event counts, revenue generated from events, <br> and user engagement metrics across the app or website. |
| [ga4_export__conversions_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__conversions_report) | [conversions_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#keyeventsreport) | Tracks key events, user actions, total revenue, and other <br> metrics for key events. Offers insights into conversion behavior. |
| [ga4_export__sessions_enhanced](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__sessions_enhanced) | n/a | This is not built off a standard report. It tracks user sessions <br> across the app or website, summarizing session engagement, start and end times, total events, and more to analyze user behavior. |

For more information, refer to the [README](https://github.com/fivetran/dbt_ga4_export/blob/main/README.md).