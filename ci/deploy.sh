#!/usr/bin/env bash

set -eu -o pipefail

# Install and update gcloud components
gcloud components install kubectl
gcloud components update
gcloud version
command -v gcloud kubectl


docker login -u="${DOCKERHUB_USERNAME}" -p="${DOCKERHUB_PASSWORD}"
docker push "akvo/akvo-reportserver:${TRAVIS_COMMIT:0:8}"
