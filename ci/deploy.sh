#!/usr/bin/env bash

set -eu -o pipefail

function log {
   echo "$(date +"%T") - BUILD INFO - $*"
}

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

docker login -u="${DOCKERHUB_USERNAME}" -p="${DOCKERHUB_PASSWORD}"
docker push "akvo/akvo-reportserver"

# Activate service account / set project
gcloud auth activate-service-account --key-file ci/gcloud-service-account.json
gcloud config set project akvo-lumen
gcloud config set container/cluster europe-west1-d
gcloud config set compute/zone europe-west1-d
gcloud config set container/use_client_certificate True

if [[ "${TRAVIS_BRANCH}" == "master" ]]; then
    log Environment is production
    gcloud container clusters get-credentials production
else
    log Environement is test
    gcloud container clusters get-credentials test
fi

# Update deployment
sed -e "s/\${TRAVIS_COMMIT}/$TRAVIS_COMMIT/" ci/k8s/deployment.yaml > deployment.yaml.tmp
kubectl apply -f deployment.yaml.tmp
kubectl apply -f ci/k8s/service.yaml
