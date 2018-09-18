FROM buildpack-deps:curl as downloader

ARG VERSION=RS3.0.4-6004-2018-08-27-10-01-33-reportserver-ce

WORKDIR /tmp

RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends unzip && \
    curl --location --output rs.zip \
    "https://sourceforge.net/projects/dw-rs/files/bin/3.0/${VERSION}.zip/download" && \
    unzip -q rs.zip -d rs && \
    rm -rf rs.zip && \
    rm -rf /tmp/rs/__MACOSX && \
    find /tmp/rs -name '.DS_Store' | xargs rm -rf

FROM tomcat:7-jre8

COPY --from=downloader /tmp/rs "${CATALINA_HOME}/webapps/reportserver/"

COPY run.sh /opt/run.sh
