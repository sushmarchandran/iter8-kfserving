#!/bin/sh
set -e -x

# Execute partial finish
source partialfinish.sh

# Apply the new InferenceService object
kubectl apply -f inferenceservice.yaml

