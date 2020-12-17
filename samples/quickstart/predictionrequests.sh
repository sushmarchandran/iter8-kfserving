#!/bin/bash

set -e

# Sending prediction requests for model versions in quickstart and e2e tests

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kfserving-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
((i=0)) || true; \
while clear; echo "Request $i"; do \
    curl https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/common/input.json | curl -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict -d @-; \
    let i=i+1; \
    sleep 0.5; \
done