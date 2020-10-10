# Iter8 bundle for KFServing

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on Kubernetes. [Iter8](https://iter8.tools) enables release automation for containerized applications and ML models on Kubernetes. This iter8-KFServing bundle brings these projects together and enables release automation for KFServing.

## Quick start on Minikube

1. Start Minikube with sufficient resources.

```
minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.17.5
```

2. Install Istio, KNative Serving, and KFServing.
```
source <(curl -s https://raw.githubusercontent.com/kubeflow/kfserving/master/hack/quick_install.sh)
```

3. Install KNative Monitoring.