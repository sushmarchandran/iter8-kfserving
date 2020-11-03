# Iter8-kfserving package

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics-driven release automation for Kubernetes and OpenShift applications. This package brings the two projects together and enables metrics-driven release automation of KFServing models on Kubernetes and OpenShift.

## Quick start on Minikube

### Setup platform

1. Start Minikube with sufficient resources.
```
minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.17.5
```

2. Git clone iter8-kfserving repo.
```
git clone https://github.com/iter8-tools/iter8-kfserving.git
```

3. Install Istio, KNative Serving, KNative Monitoring, KFServing, and iter8-kfserving.
```
cd iter8-kfserving
./common/install-everything.sh
```

4. Check KFServing controller, KNative monitoring, and iter8 pods. `Ctrl-c` after you verify pods are running.
```
kubectl get pods -n kfserving-system --watch
kubectl get pods -n knative-monitoring --watch
kubectl get pods -n iter8 --watch
```

### Setup KFServing InferenceService
5. Create InferenceService.
```
samples/common/create-inferenceservice.sh
```

6. Send a stream of prediction requests. 

7. Observe metrics for default and canary model versions in Prometheus.

### Perform iter8-kfserving experiment

8. Create automated canary rollout experiment.
```
samples/experiments/create-automated-canary-rollout-experiment.sh
```

9. The canary that you are experimenting with should succeed since it is designed to satisfy the experiment criteria. Watch as the traffic shifts from default to canary model. `Ctrl-c` after you verify experiment.
```
kubectl get inferenceservice sklearn-iris --watch
```

## Documentation

The types of experiments supported by iter8-kfserving and the metrics shipped "out-of-the-box" with iter8-kfserving are documented [here](docs/experiments.md).