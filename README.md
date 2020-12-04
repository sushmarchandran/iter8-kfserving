# Iter8-kfserving

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics-driven release automation for Kubernetes and OpenShift applications. The iter8-kfserving package brings the two projects together and enables metrics-driven release automation of KFServing models on Kubernetes and OpenShift.

## Quick start on Minikube
The following instructions illustrate automated metrics-driven canary release using iter8-kfserving on Minikube.

**Step 1:** Start Minikube with sufficient resources.
```
minikube start --cpus 4 --memory 8192 --kubernetes-version=v1.17.11 --driver=docker
```

**Step 2:** Install KFServing (including Istio and KNative serving).
```
git clone https://github.com/kubeflow/kfserving.git
cd kfserving
./hack/quick_install.sh
```

**Step 3:** Install KNative monitoring.
```
kubectl create ns knative-monitoring
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.18.0/monitoring-metrics-prometheus.yaml
```

**Step 4:** Install iter8-kfserving.
```
kustomize build github.com/iter8-tools/iter8-kfserving/install/?ref=main | kubectl apply -f -
```

**Step 5:** Check everything. `Ctrl-c` after you verify that pods are running.
```
kubectl get pods -n kfserving-system --watch
kubectl get pods -n knative-monitoring --watch
kubectl get pods -n iter8-system --watch
kubectl get metric.iter8.tools -n iter8-system
```

**Step 6:** *In a separate terminal,*, setup Minikube tunnel.
```
minikube tunnel --cleanup
```
Enter password if prompted in the above step.

**Step 7:** Create InferenceService in the `kfserving-test` namespace.
```
kubectl create ns kfserving-test
kubectl apply -f ./samples/common/sklearn-iris.yaml -n kfserving-test
```
This creates the `default` and `canary` versions of sklearn-iris model.

**Step 8:** Verify that the InferenceService is ready. `Ctrl-c` after you verify `READY==TRUE`.
```
kubectl get inferenceservice -n kfserving-test --watch
```

**Step 9:** Send prediction requests to model versions. *In a separate terminal,* export `SERVICE_HOSTNAME`, `INGRESS_HOST` and `INGRESS_PORT` environment variables, and send prediction requests to the inference service as follows.
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

**Step 10:** Create the canary rollout experiment.
```
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/experiments/example1.yaml
```

**Step 11:** Watch as the canary version succeeds and gets promoted as the new default.
```
kubectl get inferenceservice -n kfserving-test --watch
```


## Documentation

Iter8-kfserving supports a [variety of experimentation strategies](docs/experiments.md).

Iter8-kfserving supports [fourteen metrics out-of-the-box](docs/metrics_ootb.md) which you can use in your experiments.

You can [define custom metrics](docs/metrics_custom.md) and use them in your experiments.
