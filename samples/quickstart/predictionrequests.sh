#!/bin/bash

set -e

# Sending prediction requests for model versions in quickstart and e2e tests

# WORK_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
cd ${TEMP_DIR}

# Create the input file for prediction requests in ${TEMP_DIR}
curl https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/input.json -o input.json

# Environment variables needed to send requests
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export MODEL_NAME=my-model
export SERVICE_HOSTNAME=$(kubectl get isvc ${MODEL_NAME} -o jsonpath='{.status.url}' | cut -d "/" -f 3)

# Generate prediction requests (2.5 per sec)
while clear; do
    curl -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/${MODEL_NAME}:predict -d @input.json
    sleep 0.4
done
