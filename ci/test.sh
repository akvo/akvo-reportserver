#!/usr/bin/env bash

set -euo pipefail

URL="http://127.0.01:8080/reportserver/reportserver/httpauthexport?key=installation_test_report&user=testuser&apikey=TEST_API_KEY&format=PDF"

MAX_ATTEMPTS=120
ATTEMPTS=0
RS=""

echo "Waiting for ReportServer ..."
while [[ -z "${RS}" && "${ATTEMPTS}" -lt "${MAX_ATTEMPTS}" ]]; do
    sleep 1
    RS=$( (docker-compose logs --no-color report-server 2>&1 | grep -i "LateInitStartup - Startup completed") || echo "")
    let ATTEMPTS+=1
done

if [[ -z "${RS}" ]]; then
    echo "ReportServer is not available"
    exit 1
fi

docker-compose exec report-server curl -o /tmp/test-report.pdf "${URL}"
#docker-compose exec md5sum -c /tmp/test-report.pdf
