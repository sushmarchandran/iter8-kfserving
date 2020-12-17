## Installation
Follow this guide to install iter8-kfserving on Kubernetes using [Kustomize v3](https://kubectl.docs.kubernetes.io/installation/kustomize/).

### Prerequisites
1. Kubernetes 1.15+
2. [KFServing](https://github.com/kubeflow/kfserving) installed on your Kubernetes cluster

### Install iter8-kfserving
```shell
kustomize build github.com/iter8-tools/iter8-kfserving/install?ref=main | kubectl apply -f -
```

### Install iter8-monitoring
```shell
kustomize build github.com/iter8-tools/iter8-monitoring/prometheus-operator?ref=main | kubectl apply -f -
kubectl wait --for condition=established --timeout=120s crd/prometheuses.monitoring.coreos.com
kubectl wait --for condition=established --timeout=120s crd/metrics.iter8.tools
kubectl wait --for condition=established --timeout=120s crd/servicemonitors.monitoring.coreos.com
kustomize build github.com/iter8-tools/iter8-monitoring/prometheus?ref=main | kubectl apply -f -
kustomize build github.com/iter8-tools/iter8-kfserving/install/iter8-monitoring?ref=main | kubectl apply -f -
```

### Verify your installation
```shell
kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-system
kubectl wait --for condition=ready --timeout=300s pods --all -n iter8-monitoring
```

## Removal
Use the following commands to remove iter8-monitoring and iter8-kfserving from your Kubernetes cluster.
```shell
kustomize build github.com/iter8-tools/iter8-kfserving/install/iter8-monitoring?ref=main | kubectl delete -f -
kustomize build github.com/iter8-tools/iter8-monitoring/prometheus?ref=main | kubectl delete -f -
kustomize build github.com/iter8-tools/iter8-monitoring/prometheus-operator?ref=main | kubectl delete -f -
kustomize build github.com/iter8-tools/iter8-kfserving/install?ref=main | kubectl delete -f -
```
