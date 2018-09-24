#!/usr/bin/env bash

set -eu -o pipefail

docker build \
       -t akvo/akvo-reportserver:${TRAVIS_COMMIT:0:8} \
       -t akvo/akvo-reportserver:latest .
