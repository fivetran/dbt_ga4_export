{{ config(
    tags="fivetran_validations",
    enabled=(var('fivetran_validation_tests_enabled', false) and var('key_events',[]) != [])
) }}

-- this test is to make sure the rows counts are the same between versions
with prod as (
    select count(*) as prod_rows
    from {{ target.schema }}_ga4_export_prod.ga4_export__conversions_report
),

dev as (
    select count(*) as dev_rows
    from {{ target.schema }}_ga4_export_dev.ga4_export__conversions_report
)

-- test will return values and fail if the row counts don't match
select *
from prod
join dev
    on prod.prod_rows != dev.dev_rows