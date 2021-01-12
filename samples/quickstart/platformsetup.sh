#!/bin/bash

set -e

# Platform setup for quickstart and e2e tests

## Ensure Kubernetes cluster is available.
KUBERNETES_STATUS=$(kubectl version | awk '/^Server Version:/' -)
if [[ -z ${KUBERNETES_STATUS} ]]; then
    echo "Kubernetes cluster is unavailable"
    exit 1
else
    echo "Kubernetes cluster is available"
fi

## Ensure Kustomize v3 is available
KUSTOMIZE_VERSION=$(kustomize version | cut -f 1 | cut -d/ -f 2 | cut -d. -f 1)
if [[ $KUSTOMIZE_VERSION == "v3" ]]; then
    echo "Kustomize v3 is available"
else
    echo "Kustomize v3 is not available"
    echo "Get Kustomize v3 from https://kubectl.docs.kubernetes.io/installation/kustomize/"
    exit 1
fi

# Install KFServing
WORK_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR
git clone https://github.com/kubeflow/kfserving.git
cd kfserving
eval ./hack/quick_install.sh
cd $WORK_DIR

# Install iter8-kfserving
TAG=main
kustomize build github.com/iter8-tools/iter8-kfserving/install?ref=$TAG | kubectl apply -f -
kubectl wait crd -l creator=iter8 --for condition=established --timeout=120s
kustomize build github.com/iter8-tools/iter8-kfserving/install/iter8-metrics?ref=$TAG | kubectl apply -f -

# Install kfserving-monitoring
TAG=main
kustomize build github.com/iter8-tools/iter8-kfserving/install/monitoring/prometheus-operator?ref=$TAG | kubectl apply -f -
kubectl wait crd -l creator=iter8 --for condition=established --timeout=120s
kustomize build github.com/iter8-tools/iter8-kfserving/install/monitoring/prometheus?ref=$TAG | kubectl apply -f -

# Verify your installation
kubectl wait --for condition=ready --timeout=300s pods --all -n kfserving-system
kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system
kubectl wait --for condition=ready --timeout=300s pods --all -n kfserving-monitoring
