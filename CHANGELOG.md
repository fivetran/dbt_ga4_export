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

| **Table**                                                       | **GA4 Report**                                        | **Description**                                                                                                     |
|------------------------------------------------------------------|-------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| [ga4_export__traffic_acquisition_session_source_medium_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__traffic_acquisition_session_source_medium_report)     | traffic_acquisition_session_source_medium_report       | Tracks metrics including sessions, events, users, and revenue by source and medium. |
| [ga4_export__user_acquisition_first_user_source_medium_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__user_acquisition_first_user_source_medium_report)     | user_acquisition_first_user_source_medium_report       |  Tracks metrics including sessions, events, users, and revenue by first user medium and source. |
| [ga4_export__events_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__events_report)                                        | events_report                                         | Summarizes event counts, revenue generated from events, and user engagement metrics across the app or website.        |
| [ga4_export__conversions_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__conversions_report)                                   | conversions_report                                    | Tracks key events, user actions, total revenue, and other metrics for just key events. Offers insights into conversion behavior.            |
| [ga4_export__sessions_enhanced](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__sessions_enhanced)                                   | n/a                                    | Tracks user sessions across the app or website, summarizing session engagement, start and end times, total events, and more to analyze user behavior during sessions.            |

For more information, refer to the [README](https://github.com/fivetran/dbt_ga4_export/blob/main/README.md).