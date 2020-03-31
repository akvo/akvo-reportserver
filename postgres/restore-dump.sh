#!/usr/bin/env bash

set -eu

DB_HOST="${1}"
REPORTSERVER_DB_NAME="${2}"
REPORT_SERVER_USER="${3}"
SUPER_USER="${4}"
DUMP_FILE="dump.reportserver.tar.gz"

if [[ -z "${SUPERUSER_PASSWORD:-}" ]]; then
    read -r -s -p "Password for user ${SUPER_USER} for the new DB ${REPORTSERVER_DB_NAME}@${DB_HOST}: " SUPERUSER_PASSWORD
fi

export PGPASSWORD="${SUPERUSER_PASSWORD}"

echo ""

psql_settings=("--username=${SUPER_USER}" "--host=${DB_HOST}" "--dbname=${REPORTSERVER_DB_NAME}" "--set" "ON_ERROR_STOP=on")

psql "${psql_settings[@]}" --command="DROP SCHEMA public CASCADE"
gunzip --stdout "${DUMP_FILE}" | grep -v "SELECT pg_catalog.set_config" | sed 's/CREATE SCHEMA public;/CREATE SCHEMA public;\n\nCREATE EXTENSION postgis;/' | psql "${psql_settings[@]}"
psql "${psql_settings[@]}" --command="ALTER SCHEMA public OWNER TO ${REPORT_SERVER_USER}"
psql "${psql_settings[@]}" --command="REASSIGN OWNED BY postgres TO ${REPORT_SERVER_USER}"