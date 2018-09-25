#!/usr/bin/env bash

set -euo pipefail

url="http://127.0.01:8080/reportserver/reportserver/httpauthexport?key=installation_test_report&user=testuser&apikey=TEST_API_KEY&format=PDF"

max_attempts=120
attempts=0
rs=""

echo "Waiting for ReportServer ..."
while [[ -z "${rs}" && "${attempts}" -lt "${max_attempts}" ]]; do
    sleep 1
    rs=$( (docker-compose logs --no-color report-server 2>&1 | grep -i "LateInitStartup - Startup completed") || echo "")
    echo "${attempts}"
    (( attempts++ )) || :
    echo "${attempts}"
done

if [[ -z "${rs}" ]]; then
    echo "ReportServer is not available"
    exit 1
fi

docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec report-server curl -o /tmp/test-report.pdf "${url}"

docker-compose -f docker-compose.yml -f docker-compose.ci.yml exec test pdfgrep foobar /tmp/test-report.pdf
