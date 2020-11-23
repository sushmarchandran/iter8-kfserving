#!/bin/bash
set -e

# Note: This is an idempotent handler. Executing it 'n' times successfully will produce the same result as executing it once successfully. This is a useful guarantee.

# Plan of action.
## Step 0: Get the root directory.
## Step 1: Get the Experiment object.
## Step 2: Get namespace and name for InferenceService object.
## Step 3: Get the InferenceService object.
## Step 4: Find the recommended baseline.
## Step 5: Remove spec.canaryTrafficPercent in InferenceService object if field exists.
## Step 6: Replace spec.default with spec.canary and/or remove spec.canary in InferenceService object.

# Step 0: Get the root directory.
if [[ -z ${RESOURCE_DIR+x} ]]; then
    RESOURCE_DIR="./resources/experiment"
fi
echo "RESOURCE_DIR=${RESOURCE_DIR}"

# Step 1: Get the Experiment object.
echo "EXPERIMENT_NAME=${EXPERIMENT_NAME}"
echo "EXPERIMENT_NAMESPACE=${EXPERIMENT_NAMESPACE}"

if [[ -z ${EXPERIMENT_NAME+x} ]] || [[ -z ${EXPERIMENT_NAMESPACE+x} ]]; then 
    echo ""
    echo "EXPERIMENT_NAMESPACE and EXPERIMENT_NAME need to be set ..."
    exit 1
fi

kubectl get experiment ${EXPERIMENT_NAME} -n ${EXPERIMENT_NAMESPACE} -o yaml > ${RESOURCE_DIR}/experiment.yaml

# Step 2: Get namespace and name for InferenceService object.
INFERENCE_SERVICE_NN=$(yq r ${RESOURCE_DIR}/experiment.yaml spec.target)
INFERENCE_SERVICE_NAMESPACE=$(echo $INFERENCE_SERVICE_NN | cut -f1 -d/)
INFERENCE_SERVICE_NAME=$(echo $INFERENCE_SERVICE_NN | cut -f2 -d/)

if [[ -z ${INFERENCE_SERVICE_NAMESPACE+x} ]]; then
    echo "No namespace provided for InferenceService object. Defaulting it to the experiment namespace"
    INFERENCE_SERVICE_NAMESPACE=EXPERIMENT_NAMESPACE
fi

echo "INFERENCE_SERVICE_NAME=${INFERENCE_SERVICE_NAME}"
echo "INFERENCE_SERVICE_NAMESPACE=${INFERENCE_SERVICE_NAMESPACE}"

if [[ -z ${INFERENCE_SERVICE_NAME+x} ]] || [[ -z ${INFERENCE_SERVICE_NAMESPACE+x} ]]; then 
    echo "Experiment target needs to be in the form INFERENCE_SERVICE_NAMESPACE/INFERENCE_SERVICE_NAME ..."
    exit 1
fi

# Step 3: Get the InferenceService object.
echo -n "Ensuring inference service exists. Will give up after 120 seconds ..."
n=0
until [ $n -ge 120 ]; do
    INFERENCE_SERVICE_EXISTS=$(kubectl get inferenceservice ${INFERENCE_SERVICE_NAME} -n ${INFERENCE_SERVICE_NAMESPACE} --ignore-not-found)
    if [[ ! -z ${INFERENCE_SERVICE_EXISTS} ]]; then
        echo ""
        echo "Found InferenceService object ..."
        break
    fi
    echo -n "."
    sleep 1
done

if [[ -z ${INFERENCE_SERVICE_EXISTS} ]]; then
    echo "InferenceService object does not exist"
    exit 1
fi

kubectl get inferenceservice ${INFERENCE_SERVICE_NAME} -n ${INFERENCE_SERVICE_NAMESPACE} -o yaml > ${RESOURCE_DIR}/inferenceservice.yaml
echo "kubectl got the InferenceService object ..."

# Step 4: Find the recommended baseline
RECOMMENDED_BASELINE=$(yq r ${RESOURCE_DIR}/experiment.yaml status.recommendedBaseline)

if [[ -n ${RECOMMENDED_BASELINE} ]]; then 
    echo "RECOMMENDED_BASELINE=${RECOMMENDED_BASELINE}"
else
    echo "Recommended baseline is unavailable in experiment status ..."
    echo "Setting RECOMMENDED_BASELINE=default"
    RECOMMENDED_BASELINE="default"
fi

# Step 5: Remove spec.canaryTrafficPercent from InferenceService object if field exists.
CANARY_TRAFFIC_PERCENT=$(yq r ${RESOURCE_DIR}/inferenceservice.yaml spec.canaryTrafficPercent)
if [[ -n ${CANARY_TRAFFIC_PERCENT} ]]; then
    echo "Removing spec.canaryTrafficPercent ..."
    kubectl patch inferenceservice ${INFERENCE_SERVICE_NAME} -n ${INFERENCE_SERVICE_NAMESPACE} --type=json -p='[{"op": "remove", "path": "/spec/canaryTrafficPercent"}]'
fi

# Step 6: Replace spec.default with spec.canary and/or remove spec.canary in InferenceService object.
CANARY=$(yq r ${RESOURCE_DIR}/inferenceservice.yaml spec.canary)
if [[ -n ${CANARY} ]]; then
    if [[ ${RECOMMENDED_BASELINE} == "default" ]]; then
        # New default = old default. Remove spec.canary.
        echo "Removing spec.canary ..."
    else
        # New default = old canary. Store the old canary value and replace default with it.
        echo "Replacing spec.default with spec.canary and removing spec.canary ..."

        # Create a temp file to store canary as the new default.
        yq r ${RESOURCE_DIR}/inferenceservice.yaml spec.canary > ${RESOURCE_DIR}/newbaselinedata.yaml
        yq p -i ${RESOURCE_DIR}/newbaselinedata.yaml spec.default
        # Overwrite default with the stored canary.
        kubectl patch inferenceservice ${INFERENCE_SERVICE_NAME} -n ${INFERENCE_SERVICE_NAMESPACE} --type=merge --patch "$(cat ${RESOURCE_DIR}/newbaselinedata.yaml)"
    fi
    kubectl patch inferenceservice ${INFERENCE_SERVICE_NAME} -n ${INFERENCE_SERVICE_NAMESPACE} --type=json -p='[{"op": "remove", "path": "/spec/canary"}]'
fi