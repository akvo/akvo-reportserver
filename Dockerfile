FROM buildpack-deps:curl as downloader

ARG VERSION=RS3.0.4-6004-2018-08-27-10-01-33-reportserver-ce
ARG SHA256=2a0759e798e827a76af4b4ad9a36f405ba8dad251700e03119b89c374f9459f4

WORKDIR /tmp

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip=6.0-21 && \
    curl --retry 3 --location --output rs.zip \
    "https://sourceforge.net/projects/dw-rs/files/bin/3.0/${VERSION}.zip/download" && \
    echo "${SHA256}" rs.zip | sha256sum -c && \
    unzip -q rs.zip -d rs && \
    rm -rf rs.zip && \
    rm -rf /tmp/rs/__MACOSX && \
    find /tmp/rs -name '.DS_Store' -exec rm -rf {} \;

FROM tomcat:7-jre8

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client-9.6=9.6.9-0+deb9u1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=downloader /tmp/rs "${CATALINA_HOME}/webapps/reportserver/"

COPY run.sh /opt/run.sh
