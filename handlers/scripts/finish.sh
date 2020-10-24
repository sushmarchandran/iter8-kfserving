#!/bin/bash

# Note: Failure handling is yet-to-be-implemented.

# Steps 1a through 1f: Ensure assert the required pre-conditions prior to finish.

# Step 1a: Get the experiment resource yaml
kubectl get experiment $EXPERIMENT_NAME -o yaml > experiment.yaml

# Step 1b: Get the name of the baseline version resource; all names are fully qualified
BASELINE_VERSION_RESOURCE_NAME=$(yq r experiment.yaml spec.versions.baseline)

# Step 1c: Get the baseline version yaml
kubectl get version/$BASELINE_VERSION_RESOURCE_NAME -o yaml > baseline.yaml

# Step 1d: Get the name of the inference service resource
INFERENCE_SERVICE_NAME=$(yq r baseline.yaml spec.versions.baseline)

# Step 1e: Get the inference service yaml
kubectl get inferenceservice/$INFERENCE_SERVICE_NAME -o yaml > ../../resources/experiment/promote/inferenceservice/inferenceservice.yaml

# Step 1f: Get the rollForwardTo version
ROLL_FORWARD_TO_VERSION_NAME=$(yq r experiment.yaml spec.status.rollForwardTo)

# Step 2: If version to be promoted is baseline, apply baseline patch


# Step 3: If version to be promoted is candidate, apply candidate patch
