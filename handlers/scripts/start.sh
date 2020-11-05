#!/bin/sh
set -e -x

# Note: Failure handling is yet-to-be-implemented.
# A possible implementation could be as follows. If any of the steps fail (i.e., return with non-zero return code, this script returns with the non-zero error code, and the container enters failed state). 

# Note: This is an idempotent handler. Executing it 'n' times successfully will produce the same result as executing it once successfully. This is a nice and often useful robustness guarantee.

# Step 1: Get the Experiment object
kubectl get experiment $EXPERIMENT_NAME -o yaml > experiment.yaml

# Step 2: Get fully qualified resource name for InferenceService. Get the InferenceService object.
INFERENCE_SERVICE_FQRN=$(yq r experiment.yaml spec.target)
kubectl get $INFERENCE_SERVICE_FQRN -o yaml > inferenceservice.yaml

# Step 3: Get name and namespace of InferenceService object
MODEL_NAMESPACE=$(echo $INFERENCE_SERVICE_FQRN | cut -f1 -d/)
MODEL_NAME=$(echo $INFERENCE_SERVICE_FQRN | cut -f2 -d/)

# Step 4: Apply patches
if [ "$(yq r inferenceservice.yaml spec.strategy.type)" == "performance" ]; then
# Step 4.a: this is a performance experiment.
PATCH_FILE=$DOMAIN_PACKAGE_ROOT_DIR/resources/start/performancepatch.yaml
else
# Step 4.b.i: Patch the InferenceService object with 0 traffic to canary
kubectl patch -p '{"spec": {"canaryTrafficPercent": 0}}' $INFERENCE_SERVICE_FQRN

# Step 4.b.ii: Create a patch file with appropriate InferenceService name and namespace
PATCH_FILE=$DOMAIN_PACKAGE_ROOT_DIR/resources/start/patch.yaml
yq w -i $PATCH_FILE spec.versionInfo.candidates[0].weightObjRef.name $MODEL_NAME
yq w -i $PATCH_FILE spec.versionInfo.candidates[0].weightObjRef.namespace $MODEL_NAMESPACE
fi

# Step 5: Patch the experiment CR object using the appropriate patch file created in Step 4
kubectl patch experiment $EXPERIMENT_NAME --patch "$(cat $PATCH_FILE)"