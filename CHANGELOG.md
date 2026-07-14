# dbt_ga4_export v0.7.1

# dbt_ga4_export v0.7.0

[PR #18](https://github.com/fivetran/dbt_ga4_export/pull/18) includes the following updates:

## Schema/Data Changes (--full-refresh required after upgrading)
**1 total change • 1 possible breaking change**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | --- | --- | ----- |
| All models | `source_relation` column (when using a single ga4_export schema) | Empty string (`''`) | `<database>.<schema>` |  |

## Feature Updates
- Introduces the new (recommended) `ga4_export_sources` variable for more robust union data configuration. The old`ga4_export_union_schemas` and `ga4_export_union_databases` variables will still be supported. See the [README](https://github.com/fivetran/dbt_ga4_export/tree/main#define-database-and-schema-variables) for specific details.

## Under the Hood
- Adds the `fivetran_using_source_casing` variable for case-sensitive destination support. When enabled, downstream transformations respect source casing to ensure consistent results. See the [Additional Configurations](https://github.com/fivetran/dbt_ga4_export/#source-casing-for-case-sensitive-destinations) section of the README for details.
- Introduces `fivetran_utils.partition_by_source_relation` to conditionally include `source_relation` in partition clauses only when multiplesources are configured.

# dbt_ga4_export v0.6.1

[PR #15](https://github.com/fivetran/dbt_ga4_export/pull/15) includes the following updates:

## Under the Hood
- Adjusts the data type of `ga4_export_date_start` in the `quickstart.yml` from string to date.

# dbt_ga4_export v0.6.0

[PR #14](https://github.com/fivetran/dbt_ga4_export/pull/14) includes the following updates:

## Documentation
- Updates README with standardized Fivetran formatting.

## Under the Hood
- In the `quickstart.yml` file:
  - Adds `supported_vars` for Quickstart UI customization.

# dbt_ga4_export v0.5.0

[PR #13](https://github.com/fivetran/dbt_ga4_export/pull/13) includes the following updates:

## Features
  - Increases the required dbt version upper limit to v3.0.0

# dbt_ga4_export v0.4.0
[PR #12](https://github.com/fivetran/dbt_ga4_export/pull/12) includes the following updates:

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_ga4_export.yml`.
  
### Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`. 

# dbt_ga4_export v0.3.0

[PR #9](https://github.com/fivetran/dbt_ga4_export/pull/9) includes the following updates:

## Breaking Change for dbt Core < 1.9.6

> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core. This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `ga4_export` in file
`models/staging/src_ga4_export.yml`. The `freshness` top-level property should be moved
into the `config` of `ga4_export`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running GA4 Export freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `dbt_ga4_export` package. Pin your dependency on v0.2.0 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `ga4_export` source and apply freshness via the previous release top-level property route. This will require you to copy and paste the entirety of the previous release `src_ga4_export.yml` file and add an `overrides: dbt_ga4_export` property.

## Under the Hood
- Updates to ensure integration tests use latest version of dbt.

# dbt_ga4_export v0.2.0
[PR #8](https://github.com/fivetran/dbt_ga4_export/pull/8) includes the following changes:

## Breaking Changes (`--full-refresh` required after upgrading) 
- Addition of the `batch_event_index` field within the `stg_ga4_export__event` model.
- Incorporates `batch_event_index` into the generated `event_id` field. This update affects the upstream `stg_ga4_export__event` model and requires a full refresh of the downstream `int_ga4_export__derived_event_fields` model, where `event_id` is used as the unique key in incremental logic.
- Resolved an issue where `event_id` was `null` in the `stg_ga4_export__event` model when `user_pseudo_id` was missing. This was fixed by using a coalesce to substitute empty strings during concatenation.

## Documentation
- Added Quickstart model counts to README. ([#5](https://github.com/fivetran/dbt_ga4_export/pull/5))
- Corrected references to connectors and connections in the README. ([#5](https://github.com/fivetran/dbt_ga4_export/pull/5))

## Under the Hood
- Resolved bugs within the `consistency_conversions` and `integrity_events` validation tests.

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