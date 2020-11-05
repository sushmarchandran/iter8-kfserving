#!/bin/bash

# Note: Failure handling is yet-to-be-implemented.
# Note: In particular, this script should not get invoked as part of performance experiments.
# A possible implementation could be as follows. If any of the steps fail (i.e., return with non-zero return code, this script returns with the non-zero error code, and the container enters failed state). 

# Note: This is an idempotent handler. Executing it 'n' times successfully will produce the same result as executing it once successfully. This is a nice and often useful robustness guarantee.

# Step 1: Get the Experiment object
kubectl get experiment $EXPERIMENT_NAME -o yaml > experiment.yaml

# Step 2: Get fully qualified resource name for InferenceService. Get the InferenceService object.
INFERENCE_SERVICE_FQRN=$(yq r experiment.yaml spec.target)
INFERENCE_SERVICE_FILE=$DOMAIN_PACKAGE_ROOT_DIR/resources/experiment/promote/inferenceservice/inferenceservice.yaml
kubectl get $INFERENCE_SERVICE_FQRN -o yaml > $INFERENCE_SERVICE_FILE

# Step 1f: Get the recommended baseline
VERSION_TO_BE_PROMOTED=$(yq r experiment.yaml status.recommendedBaseline)

# Step 2: Modify InferenceService object.
if [ "$VERSION_TO_BE_PROMOTED" == "baseline" ]; then
    # New baseline = old baseline
    yq d $INFERENCE_SERVICE_FILE spec.canaryTrafficPercent > $INFERENCE_SERVICE_FILE
    yq d $INFERENCE_SERVICE_FILE spec.canary > $INFERENCE_SERVICE_FILE
else
    # New baseline = canary
    # check out yq's -i option so that > can be avoided
    yq d $INFERENCE_SERVICE_FILE spec.canaryTrafficPercent > $INFERENCE_SERVICE_FILE
    yq d $INFERENCE_SERVICE_FILE spec.default > $INFERENCE_SERVICE_FILE
    sed -i "s/canary:/default:/" $INFERENCE_SERVICE_FILE
fi