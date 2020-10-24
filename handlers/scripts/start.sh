#!/bin/bash

# Note: Failure handling is yet-to-be-implemented.
# A possible implementation could be as follows. If any of the steps fail (i.e., return with non-zero return code, this script returns with the non-zero error code, and the container enters failed state). 

# Note: This is an idempotent handler. Executing it 'n' times successfully will produce the same result as executing it once successfully. This is a nice and often useful robustness guarantee.

# Steps 1 and 2: Ensure assert the required pre-conditions prior to setup.

# Step 1a: Get the experiment resource yaml
kubectl get experiment $EXPERIMENT_NAME -o yaml > experiment.yaml

# Step 1d: Get the name of the inference service resource
INFERENCE_SERVICE_NAME=$(yq r baseline.yaml spec.supportingResources.$INFERENCE_SERVICE_NAME_PARAM)

# Step 1e: Get the inference service yaml
kubectl get inferenceservice/$INFERENCE_SERVICE_NAME -o yaml > inferenceservice.yaml

# Step 2: Patch the inference service with 0 traffic to canary
kubectl patch -p '{"spec": {"canaryTrafficPercent": 0}}' inferenceservice/$INFERENCE_SERVICE_NAME

# Step 3: Patch the experiment resource
kubectl patch -p '{"status": {"state": "in-progress"}}' experiment/$EXPERIMENT_NAME