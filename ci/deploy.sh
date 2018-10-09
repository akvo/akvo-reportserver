#!/usr/bin/env bash

set -eu -o pipefail

if [[ "${TRAVIS_BRANCH}" != "develop" ]] && [[ "${TRAVIS_BRANCH}" != "master" ]]; then
    exit 0
fi

if [[ "${TRAVIS_PULL_REQUEST}" != "false" ]]; then
    exit 0
fi

# Decrypt credentials
openssl aes-256-cbc -K "$encrypted_c6d1d2b426b8_key" \
	-iv "$encrypted_c6d1d2b426b8_iv" \
	-in ci/gcloud-service-account.json.enc \
	-out ci/gcloud-service-account.json -d

# Install and update gcloud components
gcloud components install kubectl
gcloud components update
gcloud version
command -v gcloud kubectl

TAG="${TRAVIS_COMMIT:0:8}"

docker login -u="${DOCKERHUB_USERNAME}" -p="${DOCKERHUB_PASSWORD}"
docker push "akvo/akvo-reportserver:${TAG}"

# Activate service account / set project
gcloud auth activate-service-account --key-file ci/gcloud-service-account.json
gcloud config set project akvo-lumen
gcloud config set container/cluster europe-west1-d
gcloud config set compute/zone europe-west1-d
gcloud config set container/use_client_certificate True

# TODO develop/master -> test/production
gcloud container clusters get-credentials test

# Update deployment
sed -i "s|akvo/akvo-reportserver:latest|akvo/akvo-reportserver:${TAG}|" ci/k8s/deployment.yaml
kubectl apply -f ci/k8s/deployment.yaml
