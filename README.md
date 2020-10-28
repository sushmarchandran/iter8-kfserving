# Iter8 package for KFServing

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on Kubernetes. [Iter8](https://iter8.tools) enables live experiments and release automation for microservices and ML models on Kubernetes. This iter8 package for KFServing domain package brings the two projects together.

## Quick start on Minikube

1. Start Minikube with sufficient resources.
```
minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.17.5
```

2. Git clone iter8-kfserving repo.
```
git clone https://github.com/iter8-tools/iter8-kfserving.git
```

3. Install Istio, KNative Serving, KNative Monitoring, and KFServing, iter8, and iter8-KFServing.
```
cd iter8-kfserving
./common/install-everything.sh
```

4. Check KFServing controller pod. `Ctrl-c` out of this command once you verify pods are running.
```
kubectl get pods -n kfserving-system --watch
```

5. Check KNative monitoring pods. `Ctrl-c` out of this command once you verify pods are running.
```
kubectl get pods -n knative-monitoring --watch
```

6. Check iter8 metrics are installed.
```
kubectl get metrics -n iter8-kfserving
```

7. Create InferenceService.
```
samples/common/create-inferenceservice.sh
```

8. Create automated canary rollout experiment.
```
samples/experiments/create-progressive-canary-rollout-experiment.sh
```

9. Watch as the traffic shifts from default to canary model. `Ctrl-c` out of this command once you verify that the experiment is working.
```
kubectl get inferenceservice sklearn-iris --watch
```