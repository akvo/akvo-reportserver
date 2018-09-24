#!/usr/bin/env bash

set -eu

JAVA_OPTS="-XX:+UseConcMarkSweepGC -Djava.awt.headless=true -Dfile.encoding=UTF8 -Drs.configdir=/opt/reportserver"
export JAVA_OPTS

mkdir -p /opt/reportserver
mkdir -p /opt/reportserver/lib
mkdir -p /opt/reportserver/config

cp "${CATALINA_HOME}/webapps/reportserver/WEB-INF/classes/persistence.properties.example" /opt/reportserver/persistence.properties
cp "${CATALINA_HOME}/webapps/reportserver/WEB-INF/classes/reportserver.properties" /opt/reportserver/reportserver.properties
cp "${CATALINA_HOME}/webapps/reportserver/WEB-INF/classes/logging-rs.properties" /opt/reportserver/logging-rs.properties

sed -i \
    -e "s|^# hibernate.connection.username=root|hibernate.connection.username=${RS_DB_USER}|" \
    -e "s|^# hibernate.connection.password=root|hibernate.connection.password=${RS_DB_PASSWORD}|" \
    -e "s|^# hibernate.dialect=net.datenwerke.rs.utils.hibernate.PostgreSQLDialect|hibernate.dialect=net.datenwerke.rs.utils.hibernate.PostgreSQLDialect|" \
    -e "s|^# hibernate.connection.driver_class=org.postgresql.Driver|hibernate.connection.driver_class=org.postgresql.Driver|" \
    -e "s|^# hibernate.connection.url=jdbc:postgresql://localhost/reportserver|hibernate.connection.url=jdbc:postgresql://${RS_DB_HOST}/${RS_DB_NAME}|" \
    /opt/reportserver/persistence.properties

## Waiting for PostgreSQL
export PGPASSWORD="${RS_DB_PASSWORD}"

MAX_ATTEMPTS=120
ATTEMPTS=0
PG=""
SQL="SELECT value FROM rs_schemainfo WHERE key_field='version'"

echo "Waiting for PostgreSQL ..."
while [[ -z "${PG}" && "${ATTEMPTS}" -lt "${MAX_ATTEMPTS}" ]]; do
    sleep 1
    PG=$((psql --username="${RS_DB_USER}" --host="${RS_DB_HOST}" --dbname="${RS_DB_NAME}" -w -t -c "${SQL}" 2>&1 | grep "RS3") || echo "")
    let ATTEMPTS+=1
done

if [[ -z "${PG}" ]]; then
    echo "PostgreSQL is not available"
    exit 1
fi

echo "PostgreSQL is ready!"

# $CATALINA_HOME/bin is in $PATH
catalina.sh run
