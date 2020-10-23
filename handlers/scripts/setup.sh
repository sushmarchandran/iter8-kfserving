#!/bin/bash

# Note: Failure handling is yet-to-be-implemented.
# A possible implementation could be as follows. If any of the steps fail (i.e., return with non-zero return code, this script returns with the non-zero error code, and the container enters failed state). 
# An alternative implementation could include sleep-retry loop for a fixed number of times.

# Note: This is an idempotent handler. Executing it 'n' times successfully will produce the same result as executing it once successfully. This is a nice and often useful robustness guarantee.

# Steps 1a through 1e: Ensure assert the required pre-conditions prior to setup.

# Step 1a: Get the experiment resource yaml
EXPERIMENT_NAME=$1
kubectl get experiment $EXPERIMENT_NAME -o yaml > experiment.yaml

# Step 1b: Get the name of the baseline version resource; all names are fully qualified
BASELINE_VERSION_RESOURCE_NAME=$(yq r experiment.yaml spec.versions.baseline)

# Step 1c: Get the baseline version yaml
kubectl get version/$BASELINE_VERSION_RESOURCE_NAME -o yaml > baseline.yaml

# Step 1d: Get the name of the inference service resource
INFERENCE_SERVICE_NAME_PARAM=$2
INFERENCE_SERVICE_NAME=$(yq r baseline.yaml spec.supportingResources.$INFERENCE_SERVICE_NAME_PARAM)

# Step 1e: Get the inference service yaml
kubectl get inferenceservice/$INFERENCE_SERVICE_NAME -o yaml > inferenceservice.yaml

# Step 2: Patch the inference service with 0 traffic to canary
kubectl patch -p '{"spec": {"canaryTrafficPercent": 0}}' inferenceservice/$INFERENCE_SERVICE_NAME

# Step 3: Patch the experiment resource
# Step 3: Revision fields can get in the way of this patch succeeding?
kubectl patch -p '{"status": {"state": "in-progress"}}' experiment/$EXPERIMENT_NAME