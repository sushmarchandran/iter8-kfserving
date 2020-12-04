# Iter8-kfserving

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics-driven release automation for Kubernetes and OpenShift applications. The iter8-kfserving package brings the two projects together and enables metrics-driven release automation of KFServing models on Kubernetes and OpenShift.

## Quick start on Minikube
The following instructions illustrate automated metrics-driven canary release using iter8-kfserving on Minikube.

**Step 1:** Start Minikube with sufficient resources.
```
minikube start --cpus 4 --memory 8192 --kubernetes-version=v1.17.11 --driver=docker
```

**Step 2:** Git clone iter8-kfserving.
```
git clone https://github.com/iter8-tools/iter8-kfserving.git
```

**Step 3:** Install KFServing, KNative monitoring, and iter8-kfserving. This step takes a couple of minutes.
```
cd iter8-kfserving
export ITER8_KFSERVING_ROOT=$PWD
./quickstart/install-everything.sh
```

**Step 4:** Verify that pods are running.
```
kubectl wait --for condition=ready --timeout=180s pods --all -n kfserving-system
kubectl wait --for condition=ready --timeout=180s pods --all -n knative-monitoring
kubectl wait --for condition=ready --timeout=180s pods --all -n iter8-system
```

**Step 5:** *In a separate terminal,*, setup Minikube tunnel.
```
minikube tunnel --cleanup
```
Enter password if prompted in the above step.

**Step 6:** Create InferenceService in the `kfserving-test` namespace.
```
kubectl create ns kfserving-test
kubectl apply -f samples/common/sklearn-iris.yaml -n kfserving-test
```
This creates the `default` and `canary` versions of sklearn-iris model.

**Step 7:** Verify that the InferenceService is ready. This step takes a couple of minutes.
```
kubectl wait --for condition=ready --timeout=180s inferenceservice/sklearn-iris -n kfserving-test
```

**Step 8:** Send prediction requests to model versions. *In a separate terminal,* from your iter8-kfserving folder, export `SERVICE_HOSTNAME`, `INGRESS_HOST` and `INGRESS_PORT` environment variables, and send prediction requests to the inference service as follows.
```
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kfserving-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
watch -n 1.0 'curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict -d @./samples/common/input.json'
```

<!-- ### Observe metrics

9.*In a separate terminal,* port forward Prometheus so that you can observe metrics for default and canary model versions.

```
kubectl port-forward -n knative-monitoring \
$(kubectl get pods -n knative-monitoring \
--selector=app=prometheus --output=jsonpath="{.items[0].metadata.name}") \
9090
```
You can now access the Prometheus UI at `http://localhost:9090`. -->

**Step 9:** Create the canary rollout experiment.
```
kubectl apply -f samples/experiments/example1.yaml
```

**Step 10:** Watch as the canary version succeeds and gets promoted as the new default.
```
kubectl get inferenceservice -n kfserving-test --watch
```


## Documentation

Iter8-kfserving supports a [variety of experimentation strategies](docs/experiments.md).

Iter8-kfserving supports [fourteen metrics out-of-the-box](docs/metrics_ootb.md) which you can use in your experiments.

You can [define custom metrics](docs/metrics_custom.md) and use them in your experiments.
