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

| **Table**                                                       | **GA4 Report**                                        | **Description**                                                                                                     |
|------------------------------------------------------------------|-------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| ga4_export__traffic_acquisition_session_source_medium_report     | traffic_acquisition_session_source_medium_report       | Tracks metrics including sessions, events, users, and revenue by source and medium. |
| ga4_export__user_acquisition_first_user_source_medium_report     | user_acquisition_first_user_source_medium_report       |  Tracks metrics including sessions, events, users, and revenue by first user medium and source. |
| ga4_export__events_report                                        | events_report                                         | Summarizes event counts, revenue generated from events, and user engagement metrics across the app or website.        |
| ga4_export__conversions_report                                   | conversions_report                                    | Tracks key events, user actions, total revenue, and other metrics for just key events. Offers insights into conversion behavior.            |

<!--section-end-->


## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran GA4 Export connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

#### Database Incremental Strategies
Many of the models in this package are materialized incrementally, so we have configured our models to work with the different strategies available to each supported warehouse.

For **BigQuery** and **Databricks All Purpose Cluster runtime** destinations, we have chosen `insert_overwrite` as the default strategy, which benefits from the partitioning capability.
> For Databricks SQL Warehouse destinations, models are materialized as tables without support for incremental runs.

For **Snowflake**, **Redshift**, and **Postgres** databases, we have chosen `delete+insert` as the default strategy.

> Regardless of strategy, we recommend that users periodically run a `--full-refresh` to ensure a high level of data quality.

### Step 2: Install the package
Include the following ga4_export package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yaml
packages:
  - package: fivetran/ga4_export
    version: [">=0.1.0", "<0.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```
#### Connector Restrictions
This package is suited for connectors using the default *column* sync mode, as opposed to the *json* sync mode. Additionally, it assumes the underlying schema for the connector version synced after July 24, 2023.

For more information on the underlying schema, please refer to the [connector docs](https://fivetran.com/docs/connectors/applications/google-analytics-4-export#schemainformation) and [Google Analytic's documentation on the Export schema](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001#zippy=%2Cevent).

#### Discrepanices Between GA4 Export vs GA4 Reports
It’s common to see discrepancies when comparing GA4 exported data, which is used in this package, against GA4 reports (such as the ones in the GA4 UI). This can be due to various reasons, including the UI using sampled data, approximated cardinality for metrics, or the grain at which metrics are aggregated.

For example, your GA4 `user_acquisition_first_user_source_medium` prebuilt report may show a daily event count of 6836 for a certain source and medium while the `ga4_export__user_acquisition_first_user_source_medium_report` model will show 6765.

For more information on why this may occur, please refer to the below articles (Including the official Google Analytic articles as well as 3rd party blogs): 

- https://developers.google.com/analytics/blog/2023/bigquery-vs-ui
- https://www.cardinalpath.com/blog/ga4-and-bigquery-why-might-data-not-match 

#### Intraday Events
The GA4 Export Connector [syncs data from intraday tables](
https://fivetran.com/docs/connectors/applications/google-analytics-4-export#syncingeventsfromintradaytables) throughout the day, and syncs daily tables at the end of the day. Events from the intraday tables are flagged by an `is_intraday` field in the `event` table. To avoid duplication and since the models in this package are built upon daily tables, we filter out the intraday events in the staging `stg_ga4_export` model.

#### Key Events
According to Google Analytics, a key event is an event that's particularly important to the success of your company.

Because a key event may differ across companies, we require you specify your list of these events. Otherwise, the package will assume no key events. 

This will be applied in the `ga4_export__conversions_report` model which filters the `events_report` to just key events. Additionally this will manifest in the `key_events` field in `ga4_export__traffic_acquisition_session_source_medium_report` and `ga4_export__user_acquisition_first_user_source_medium_report`.

To configure your key events, add the following variable to your `dbt_project.yml` file.

```yml
vars:
  ga4_export:
    key_events: ['click','trial_signup'] # example key events
```

### Step 3: Define database and schema variables
By default, this package runs using your destination and the `ga4_export` schema. If this is not where your GA4 Export data is (for example, if your GA4 Export schema is named `ga4_export_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    ga4_export_database: your_database_name
    ga4_export_schema: your_schema_name 
```

### (Optional) Step 4: Additional configurations
<details open><summary>Collapse/expand details</summary>

#### Event Date Range
Because of the typical volume of event data, you may want to limit this package's models to work with a recent date range of your GA4 Export data (however, note that all final models are materialized as [incremental](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/materializations#incremental) tables).

By default, the package looks at all events since January 1, 2024. To change this start date, add the following variable to your `dbt_project.yml` file:

```yml
vars:
  ga4_export:
    ga4_export_date_start: 'yyyy-mm-dd' 
```

##### Lookback Window
Events can sometimes arrive late. Since many of the models in this package are incremental, by default we look back 7 days to ensure late arrivals are captured while avoiding requiring a full refresh. To change the default lookback window, add the following variable to your `dbt_project.yml` file:

```yml
vars:
  ga4_export:
    lookback_window: number_of_days # default is 7
```

#### Changing the Build Schema
By default this package will build the GA4 Export staging models within a schema titled (<target_schema> + `_stg_ga4_export`) and GA4 Export final models within a schema titled (<target_schema> + `ga4_export`) in your target database. If this is not where you would like your modeled GA4 Export data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
models:
    ga4_export:
      +schema: my_new_schema_name # leave blank for just the target_schema
      staging:
        +schema: my_new_schema_name # leave blank for just the target_schema
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_ga4_export/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    ga4_export_<default_source_table_name>_identifier: your_table_name 
```

### Event De-Duplication 

</details>

### (Optional) Step 5: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/ga4_export/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_ga4_export/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_ga4_export/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).