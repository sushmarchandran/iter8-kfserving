#!/bin/bash

set -e

# Platform setup for e2e tests

## Ensure Minikube is running with sufficient resources
HOST_STATUS=$(minikube status | awk '/^host:/' - | cut -d ' ' -f 2)
if [[ $HOST_STATUS == "Running" ]]; then
    echo "Minikube host is up"
else
    echo "Minikube host is down"
    exit 1
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
git clone --branch v0.4.1 https://github.com/kubeflow/kfserving.git
cd kfserving
eval ./hack/quick_install.sh
cd $WORK_DIR

# Install iter8-kfserving
kustomize build github.com/iter8-tools/iter8-kfserving/install?ref=main | kubectl apply -f -

# Install iter8-monitoring
kustomize build github.com/iter8-tools/iter8-monitoring/prometheus-operator?ref=main | kubectl apply -f -
kubectl wait --for condition=established --timeout=120s crd/prometheuses.monitoring.coreos.com
kubectl wait --for condition=established --timeout=120s crd/metrics.iter8.tools
kubectl wait --for condition=established --timeout=120s crd/servicemonitors.monitoring.coreos.com
kustomize build github.com/iter8-tools/iter8-monitoring/prometheus?ref=main | kubectl apply -f -
kustomize build github.com/iter8-tools/iter8-kfserving/install/iter8-monitoring?ref=main | kubectl apply -f -

# Verify pods
kubectl wait --for condition=ready --timeout=300s pods --all -n kfserving-system
kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system
kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-monitoring