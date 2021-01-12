#!/bin/bash

set -e

# InferenceService setup for quickstart

kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/default.yaml
echo "created default model"
echo "waiting for InferenceService object to be ready..."
kubectl wait isvc/my-model --for condition=Ready --timeout=180s
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/canary.yaml
echo "created canary model"
echo "waiting for InferenceService object to be ready"
kubectl wait isvc/my-model --for condition=Ready --timeout=180s
echo "InferenceService object is ready"

