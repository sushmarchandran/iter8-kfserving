#!/bin/sh
set -e -x

# Step 1: Execute partial finish
source partialfinish.sh

# The following is an incomplete example inspired by https://github.com/ShadowApex/docker-git-push
# This can be completed along the same lines as the entrypoint.sh script in the above repo.

# Step 2: Get the patched INFERENCE_SERVICE_FILE. Patching is done by partialfinish.sh
INFERENCE_SERVICE_FILE=$DOMAIN_PACKAGE_ROOT_DIR/resources/experiment/promote/inferenceservice.yaml

# Change to our working directory
cd ${WORKING_DIR}

echo "Initializing repository."
git init 
git remote add ${GIT_ORIGIN} ${GIT_REPO}
git fetch
git checkout -t ${GIT_ORIGIN}/${GIT_BRANCH}

# Git push the new InferenceService object
cp $INFERENCE_SERVICE_FILE .
git add inferenceservice.yaml
git commit -m "Inference service from experiment $EXPERIMENT_NAME"
git push ${GIT_ORIGIN} ${GIT_BRANCH}


