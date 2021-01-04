#!/bin/bash

set -e

# InferenceService setup for quickstart and e2e tests

kubectl create ns kfserving-test || true
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/common/sklearn-iris.yaml -n kfserving-test
kubectl wait --for condition=ready --timeout=180s inferenceservice/sklearn-iris -n kfserving-test
