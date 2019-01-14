#!/usr/bin/env bash

set -eu -o pipefail

docker build \
       -t "akvo/akvo-reportserver:${TRAVIS_COMMIT}" \
       -t "akvo/akvo-reportserver:latest" .

docker-compose -f docker-compose.yml -f docker-compose.ci.yml up --build -d

./ci/test.sh
