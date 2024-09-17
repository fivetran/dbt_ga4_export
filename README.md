<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_ga4_export/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

# GA4 Export dbt Package ([docs](https://github.com/fivetran/dbt_ga4_export))
## What does this dbt package do?
- Produces modeled tables that leverage GA4 Export data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/google-analytics-4-export) in the format described by [this ERD](https://docs.google.com/presentation/d/1LQSEVYhS5pD2ut03bH68kvEBdLjmD9j1w9EV76fJKPE/edit#slide=id.g259e9319939_0_3).

<!--section="ga4_export_transformation_model"-->
These tables are designed to replicate common GA4 reports. The following provides a list of all tables provided by this package along with their corresponding GA4 report.
> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_ga4_export/#!/overview?).

| **Table** | **GA4 Report** | **Description** |
|---|---|---|
| ga4_export__traffic_acquisition_session_source_medium_report | traffic_acquisition_session_source_medium_report |  x |
| ga4_export__user_acquisition_first_user_source_medium_report | user_acquisition_first_user_source_medium_report | x  |
| ga4_export__events_report | events_report | x  |
| ga4_export__conversions_report | conversions_report |  x |

<!--section-end-->

# WORK IN PROGRESS!


<!-- there are two sync modes from the connector. call out that this package is only for the columns sync mode, not the json sync mode -->