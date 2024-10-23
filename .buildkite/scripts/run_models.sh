#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
if [ "$db" = "databricks-sql" ]; then
# Normal dbt run with full refresh
dbt seed --vars '{ga4_export_schema: ga4_export_sqlw_tests}' --target "$db" --full-refresh
dbt compile --vars '{ga4_export_schema: ga4_export_sqlw_tests}' --target "$db"
dbt run --vars '{ga4_export_schema: ga4_export_sqlw_tests}' --target "$db" --full-refresh
dbt test --vars '{ga4_export_schema: ga4_export_sqlw_tests}' --target "$db"

# Normal dbt run without full refresh
dbt run --vars '{ga4_export_schema: ga4_export_sqlw_tests}' --target "$db"
dbt test --vars '{ga4_export_schema: ga4_export_sqlw_tests}'  --target "$db"

# dbt run with key_events variable
dbt run --vars '{ga4_export_schema: ga4_export_sqlw_tests, key_events: ['purchase']}' --target "$db"
dbt test --vars '{ga4_export_schema: ga4_export_sqlw_tests}' --target "$db"

else
# Normal dbt run with full refresh
dbt seed --target "$db" --full-refresh
dbt compile --target "$db"
dbt run --target "$db" --full-refresh
dbt test --target "$db"

# Normal dbt run without full refresh
dbt run --target "$db"
dbt test --target "$db"

# dbt run with key_events variable
dbt run --vars '{key_events: ['purchase']}' --target "$db"
dbt test --target "$db"
fi
dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"
