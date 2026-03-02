<!--section="ga4-export_transformation_model"-->
# GA4 Export dbt Package

This dbt package transforms data from Fivetran's GA4 Export connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 7
- Connector documentation
  - [GA4 Export connector documentation](https://fivetran.com/docs/connectors/applications/google-analytics-4-export)
  - [GA4 Export ERD](https://fivetran.com/docs/connectors/applications/google-analytics-4-export#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_ga4_export)
  - [dbt Docs](https://fivetran.github.io/dbt_ga4_export/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_ga4_export/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_ga4_export/blob/main/CHANGELOG.md)
- dbt Core™ supported versions
  - `>=1.3.0, <3.0.0`

## What does this dbt package do?
This package enables you to produce modeled tables that leverage GA4 Export data and replicate common GA4 reports. It creates enriched models with metrics focused on traffic acquisition, user acquisition, events, conversions, and session analysis.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_ga4_export
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [ga4_export__traffic_acquisition_session_source_medium_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__traffic_acquisition_session_source_medium_report) | Analyzes session-level traffic acquisition to understand which sources and mediums drive website sessions, user engagement, and revenue. Corresponds to the [traffic_acquisition_session_source_medium_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#trafficacquisitionsessionsourcemediumreport) GA4 report. <br></br>**Example Analytics Questions:**<ul><li>Which traffic sources and mediums generate the most sessions and revenue?</li><li>How do engagement metrics vary across different acquisition channels?</li><li>What is the average session duration and event count by source/medium combination?</li></ul> |
| [ga4_export__user_acquisition_first_user_source_medium_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__user_acquisition_first_user_source_medium_report) | Tracks first-touch attribution to identify where new users originally come from and measure user acquisition effectiveness by source and medium. Corresponds to the [user_acquisition_first_user_source_medium_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#useracquisitionfirstusersourcemediumreport) GA4 report. <br></br>**Example Analytics Questions:**<ul><li>Which first-touch channels are most effective at acquiring new users?</li><li>How do first user sources compare in terms of session quality and revenue generation?</li><li>What is the total number of new users acquired by each source/medium combination?</li></ul> |
| [ga4_export__events_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__events_report) | Summarizes event activity across your digital properties to analyze user interactions, engagement patterns, and revenue generated from specific events. Corresponds to the [events_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#eventsreport) GA4 report. <br></br>**Example Analytics Questions:**<ul><li>Which events are triggered most frequently and generate the most revenue?</li><li>How do average events per user vary across different event types?</li><li>What is the average revenue per event by event type?</li></ul> |
| [ga4_export__conversions_report](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__conversions_report) | Tracks key events (conversions) to measure goal completions, user actions, and total revenue to understand conversion behavior and performance. Corresponds to the [conversions_report](https://fivetran.com/docs/connectors/applications/google-analytics-4/prebuilt-reports#keyeventsreport) GA4 report. <br></br>**Example Analytics Questions:**<ul><li>Which key events have the highest conversion rates and total revenue?</li><li>How do key event completion rates vary across different time periods?</li><li>What is the average revenue per key event completion?</li></ul> |
| [ga4_export__sessions_enhanced](https://fivetran.github.io/dbt_ga4_export/#!/model/model.ga4_export.ga4_export__sessions_enhanced) | Enriches session data with engagement metrics, event counts, and timing information to provide comprehensive session-level analytics for understanding user behavior patterns. <br></br>**Example Analytics Questions:**<ul><li>What is the average session duration and total events per session?</li><li>Which sessions result in high engagement or conversion events?</li><li>How do session start and end times correlate with user engagement levels?</li></ul> |

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran GA4 Export connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

#### Connector Restrictions
This package is designed for connections using the [default *column* sync mode](https://fivetran.com/docs/connectors/applications/google-analytics-4-export#columnsmode), not the *json* sync mode. It also assumes the [underlying schema](https://fivetran.com/docs/connectors/applications/google-analytics-4-export#schemainformation) corresponds to connector versions synced after July 24, 2023.

For more information on the underlying schema, please refer to the [connector docs](https://fivetran.com/docs/connectors/applications/google-analytics-4-export#schemainformation) and [Google Analytics' documentation on the Export schema](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001#zippy=%2Cevent).

#### Database Incremental Strategies
Many of the models in this package are materialized incrementally, so we have configured our models to work with the different strategies available to each supported warehouse.

For **BigQuery** and **Databricks All Purpose Cluster runtime** destinations, we have chosen `insert_overwrite` as the default strategy, which benefits from the partitioning capability.
> For Databricks SQL Warehouse destinations, models are materialized as tables without support for incremental runs.

For **Snowflake**, **Redshift**, and **Postgres** databases, we have chosen `delete+insert` as the default strategy.

> Regardless of strategy, we recommend that users periodically run a `--full-refresh` to ensure a high level of data quality.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_ga4_export/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following ga4_export package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yaml
packages:
  - package: fivetran/ga4_export
    version: [">=0.6.0", "<0.7.0"] # we recommend using ranges to capture non-breaking changes automatically
```

### Define database and schema variables
#### Single connection
By default, this package runs using your destination and the `ga4_export` schema. If this is not where your GA4 Export data is (for example, if your GA4 Export schema is named `ga4_export_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  ga4_export_database: your_database_name
  ga4_export_schema: your_schema_name 
```
#### Union multiple connections
If you have multiple GA4 Export connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `ga4_export_union_schemas` OR `ga4_export_union_databases` variables (cannot do both) in your root `dbt_project.yml` file. Below are the variables and examples:

```yml
vars:
    ga4_export_union_schemas: ['ga4_export_test_one', 'ga4_export_test_two']
    ga4_export_union_databases: ['ga4_export_test_one', 'ga4_export_test_two']
```

The native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

### (Optional) Additional configurations and data integrity notices

#### Event Date Range
Because of the typical volume of event data, you may want to limit this package's models to work with a recent date range of your GA4 Export data (however, note that all final models are materialized as [incremental](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/materializations#incremental) tables).

By default, the package looks at all events since January 1, 2024. To change this start date, add the following variable to your `dbt_project.yml` file:

```yml
vars:
  ga4_export:
    ga4_export_date_start: 'yyyy-mm-dd' ## default is '2024-01-01'
```

#### Discrepancies Between GA4 Export vs GA4 Reports
It's common to see discrepancies when comparing GA4 exported data, which is used in this package, against GA4 reports (such as the ones in the GA4 UI). This can be due to various reasons, including the UI using sampled data, approximated cardinality for metrics, or the grain at which metrics are aggregated.

For example, your GA4 `user_acquisition_first_user_source_medium` prebuilt report with the GA4 UI may show a daily event count of 6836 for a certain source and medium while the `ga4_export__user_acquisition_first_user_source_medium_report` model from this dbt package will show 6765.

For more information on why this may occur, please refer to the below articles (Including the official Google Analytics articles as well as 3rd party blogs): 

- [BigQuery export vs UI](https://developers.google.com/analytics/blog/2023/bigquery-vs-ui)
- [GA4 and BigQuery: why might data not match?](https://www.cardinalpath.com/blog/ga4-and-bigquery-why-might-data-not-match)

#### Intraday Events
The GA4 Export Connector [syncs data from intraday tables](
https://fivetran.com/docs/connectors/applications/google-analytics-4-export#syncingeventsfromintradaytables) throughout the day, and syncs daily tables at the end of the day. Events from the intraday tables are flagged by an `is_intraday` field in the `event` table. To avoid duplication and since the models in this package are built upon daily tables, we filter out the intraday events in the staging `stg_ga4_export` model.

#### Key Events
According to Google Analytics, a key event is an event that's particularly important to the success of your company. Because a key event may differ across companies, we require you specify your list of these events. Otherwise, the package will assume no key events. This will be applied in the `ga4_export__conversions_report` model which filters the `events_report` to just key events. Additionally this will manifest in the `key_events` field in `ga4_export__traffic_acquisition_session_source_medium_report` and `ga4_export__user_acquisition_first_user_source_medium_report`. To configure your key events, add the following variable to your `dbt_project.yml` file.

```yml
vars:
  ga4_export:
    key_events: ['click','trial_signup'] # example key events
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

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).
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

<!--section="ga4-export_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/ga4_export/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_ga4_export/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_ga4_export/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).