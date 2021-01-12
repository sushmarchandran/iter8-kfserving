#!/bin/bash

set -e

# Sending prediction requests for model versions in quickstart and e2e tests

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

export MODEL_NAME=my-model

export SERVICE_HOSTNAME=$(kubectl get isvc ${MODEL_NAME} -o jsonpath='{.status.url}' | cut -d "/" -f 3)

while clear; do
    curl https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/input.json | curl -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/${MODEL_NAME}:predict -d @-
    sleep 0.5
done
