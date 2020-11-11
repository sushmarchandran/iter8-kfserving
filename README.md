# Iter8-kfserving package

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics-driven release automation for Kubernetes and OpenShift applications. This package brings the two projects together and enables metrics-driven release automation of KFServing models on Kubernetes and OpenShift.

## Quick start on Minikube

### Setup Minikube

1. Start Minikube with sufficient resources.

```
minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.17.11
```

2. Setup Minikube tunnel (in a separate terminal) (Optional, recommended) 

```
minikube tunnel --cleanup
```

### Install Istio, KNative Serving, KNative Monitoring, KFServing, and iter8-kfserving

3. Git clone iter8-kfserving repo.

```
git clone https://github.com/iter8-tools/iter8-kfserving.git
```

4. Install everything.

```
cd iter8-kfserving
export ITER8_KFSERVING_ROOT=$PWD
./quickstart/install-everything.sh
```
The `export` command in the above step is required for correct functioning of the scripts.

5. Check everything. `Ctrl-c` after you verify pods are running.

```
kubectl get pods -n kfserving-system --watch
kubectl get pods -n knative-monitoring --watch
```
Note: Two more watches for iter8 pods and iter8-kfserving resources are yet to be added above.

### Create KFServing InferenceService

6. Create InferenceService in the `kfserving-test` namespace.

```
kubectl create ns kfserving-test
kubectl apply -f ./samples/common/sklearn-iris.yaml -n kfserving-test
```
This creates the `default` and `canary` versions of sklearn-iris model and splits prediction requests between them.

7. Verify that the InferenceService is ready. `Ctrl-c` after you verify `READY==TRUE`.

```
kubectl get inferenceservice -n kfserving-test --watch
```

### Send prediction requests to model versions

8. Send a stream of prediction requests (in a separate terminal). In order for this step to work, you need to export `SERVICE_HOSTNAME`, `INGRESS_HOST` and `INGRESS_PORT` environment variables following instructions [here](https://github.com/kubeflow/kfserving#determine-the-ingress-ip-and-ports).

```
watch -n 1.0 'curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}/v1/models/sklearn-iris:predict -d @./.tmp/kfserving/docs/samples/rollouts/input.json'
```

### Observe metrics

9. Port forward Prometheus (in a separate terminal) so that you can observe metrics for default and canary model versions. You follow the instructions from [this page](https://knative.dev/v0.15-docs/serving/accessing-metrics/) or use the command below.

```
kubectl port-forward -n knative-monitoring \
$(kubectl get pods -n knative-monitoring \
--selector=app=prometheus --output=jsonpath="{.items[0].metadata.name}") \
9090
```
You can access the Prometheus UI at `http://localhost:9090`.

### Perform iter8-kfserving experiment

Coming soon.

<!-- 8. Create automated canary rollout experiment.
```
samples/experiments/create-automated-canary-rollout-experiment.sh
```

9. The canary that you are experimenting with should succeed since it is designed to satisfy the experiment criteria. Watch as the traffic shifts from default to canary model. `Ctrl-c` after you verify experiment.
```
kubectl get inferenceservice sklearn-iris --watch
``` -->

## Documentation

The types of experiments supported by iter8-kfserving and the metrics shipped "out-of-the-box" with iter8-kfserving are documented [here](docs/experiments.md).