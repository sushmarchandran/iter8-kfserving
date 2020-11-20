# Iter8-kfserving package

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics-driven release automation for Kubernetes and OpenShift applications. This package brings the two projects together and enables metrics-driven release automation of KFServing models on Kubernetes and OpenShift.

## Quick start on Minikube

### Start Minikube

1. Start Minikube with sufficient resources

```
minikube start --cpus 4 --memory 8192 --kubernetes-version=v1.17.11 --driver=docker
```

### Install Istio, KNative Serving, KNative Monitoring, KFServing, and iter8-kfserving

2. Git clone iter8-kfserving repo.

```
git clone https://github.com/iter8-tools/iter8-kfserving.git
```

3. Install everything.

```
cd iter8-kfserving
export ITER8_KFSERVING_ROOT=$PWD
./quickstart/install-everything.sh
```
The `export` command in the above step is required for correct functioning of the scripts.

4. Check everything. `Ctrl-c` after you verify that pods are running using the watches.

```
kubectl get pods -n kfserving-system --watch
kubectl get pods -n knative-monitoring --watch
kubectl get pods -n iter8 --watch
kubectl get metrics -n iter8
```

### Setup Minikube tunnel

5. *In a separate terminal,*, setup Minikube tunnel.

```
minikube tunnel --cleanup
```

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

8. *In a separate terminal,* export `SERVICE_HOSTNAME`, `INGRESS_HOST` and `INGRESS_PORT` environment variables, and send prediction requests to the inference service as follows.

```
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kfserving-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
watch -n 1.0 'curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict -d @./samples/common/input.json'
```

### Observe metrics

9.*In a separate terminal,* port forward Prometheus so that you can observe metrics for default and canary model versions.

```
kubectl port-forward -n knative-monitoring \
$(kubectl get pods -n knative-monitoring \
--selector=app=prometheus --output=jsonpath="{.items[0].metadata.name}") \
9090
```
You can now access the Prometheus UI at `http://localhost:9090`.

### Perform iter8-kfserving experiment

10. Create the canary rollout experiment.

11. Watch the progress of the experiment.

12. Watch the canary version succeeding and getting promoted as the new default.

Note: The canary that you are experimenting with should succeed since it is designed to satisfy the experiment criteria.

## Documentation

The various types of experimentation strategies supported by iter8-kfserving and the metrics shipped "out-of-the-box" with iter8-kfserving are documented [here](docs/experiments.md).