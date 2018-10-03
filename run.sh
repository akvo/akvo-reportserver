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

#modify reportserver.properties
sed -i \
    -e "s|^    rs.crypto.pbe.salt = The salt to be used for encryption. This should simply be a long string.|rs.crypto.pbe.salt=${RS_PBE_SALT}|" \
    -e "s|^    rs.crypto.pbe.passphrase = The Passphrase|rs.crypto.pbe.passphrase=${RS_PBE_PASSPHRASE}|" \
    -e "s|^     rs.crypto.passwordhasher.hmac.passphrase = This is the Passphrase used to compute the HMAC key for reportServer passwords.|rs.crypto.passwordhasher.hmac.passphrase=${RS_HMAC_PASSPHRASE}|" \
    /opt/reportserver/reportserver.properties


## Waiting for PostgreSQL
export PGPASSWORD="${RS_DB_PASSWORD}"

max_attempts=120
attempts=0
pg=""
sql="SELECT value FROM rs_schemainfo WHERE key_field='version'"

echo "Waiting for PostgreSQL ..."
while [[ -z "${pg}" && "${attempts}" -lt "${max_attempts}" ]]; do
    sleep 1
    pg=$( (psql --username="${RS_DB_USER}" --host="${RS_DB_HOST}" --dbname="${RS_DB_NAME}" -w -t -c "${sql}" 2>&1 | grep "RS3") || echo "")
    (( attempts++ )) || :
done

if [[ -z "${pg}" ]]; then
    echo "PostgreSQL is not available"
    exit 1
fi

echo "PostgreSQL is ready!"

# $CATALINA_HOME/bin is in $PATH
catalina.sh run
