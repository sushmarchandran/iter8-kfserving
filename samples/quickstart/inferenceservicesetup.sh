#!/bin/bash

set -e

# InferenceService setup for quickstart

kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/default.yaml
kubectl wait isvc/my-model --for condition=Ready --timeout=180s
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/canary.yaml
kubectl wait isvc/my-model --for condition=Ready --timeout=180s

