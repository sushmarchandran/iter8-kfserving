# Iter8 bundle for KFServing

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on Kubernetes. [Iter8](https://iter8.tools) enables release automation for containerized applications and ML models on Kubernetes. This iter8-KFServing bundle brings these projects together and enables release automation for KFServing.

## Quick start on Minikube

1. Start Minikube with sufficient resources.
```
minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.17.5
```

2. Git clone iter8-kfserving repo.
```
git clone https://github.com/iter8-tools/iter8-kfserving.git
```

3. Install Istio, KNative Serving, KNative Monitoring, and KFServing.
```
cd iter8-kfserving
source bin/install-everything.sh
```

4. Check KFServing and KNative monitoring installations
```
kubectl get pods -n kfserving-system --watch
kubectl get pods -n knative-monitoring --watch
```