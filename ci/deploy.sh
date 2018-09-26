#!/usr/bin/env bash

set -eu -o pipefail


docker login -u="${DOCKERHUB_USERNAME}" -p="${DOCKERHUB_PASSWORD}"
docker push "akvo/akvo-reportserver:${TRAVIS_COMMIT:0:8}"
