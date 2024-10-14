{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

-- this test is to make sure the rows counts are the same between versions
with prod as (
    select 
        event_date,
        source_relation,
        session_medium,
        session_source,
        count(*) as prod_rows
    from {{ target.schema }}_ga4_export_prod.ga4_export__traffic_acquisition_session_source_medium_report
    group by 1,2,3,4
),

dev as (
    select
        event_date,
        source_relation,
        session_medium,
        session_source,
        count(*) as dev_rows
    from {{ target.schema }}_ga4_export_dev.ga4_export__traffic_acquisition_session_source_medium_report
    group by 1,2,3,4
)

-- test will return values and fail if the row counts don't match
select *
from prod
join dev
    on prod.prod_rows != dev.dev_rows