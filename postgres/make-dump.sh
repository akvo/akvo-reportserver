#!/usr/bin/env bash

set -eu

DB_HOST="${1}"
REPORTSERVER_DB="${2}"
REPORTSERVER_USER="${3}"
DUMP_FILE="dump.reportserver.tar.gz"

read -r -s -p "Password for ${REPORTSERVER_USER} for DB ${REPORTSERVER_DB}@${DB_HOST}: " PASSWORD

echo ""
echo "Starting dump ..."

PGPASSWORD="${PASSWORD}" pg_dump --schema=public --blobs --host="${DB_HOST}" --username="${REPORTSERVER_USER}" --no-acl --no-owner "${REPORTSERVER_DB}" | gzip > "${DUMP_FILE}"
