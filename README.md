# Iter8-kfserving
> [KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics and AI-driven live experiments, progressive delivery, and rollout optimization for Kubernetes and OpenShift applications. The iter8-kfserving domain package brings the two projects together.

The picture below illustrates progressive canary rollout of a KFServing model using iter8.

![Progressive canary rollout orchestrated by iter8-kfserving](docs/images/iter8kfservingquickstart.png)

## Table of Contents
- [Quick start on Minikube](#Quick-start-on-Minikube)
- [Installation](./docs/installation.md)
- [Anatomy of an iter8 experiment](./docs/anatomy.md)
- [Progressive canary release experiment](./docs/canary.md)
- Metrics
  * Anatomy of a metric
  * Using metrics in an experiment
  * [Out-of-the-box metrics](./docs/metrics_ootb.md)
  * [Defining a custom metric](./docs/metrics_custom.md)
- Concurrent experiments
- Reference
  * Experiment CRD
  * Metrics CRD
- [Under the hood](./docs/underthehood.md)
- [Roadmap](./docs/roadmap.md)
- [Contributing](./docs/roadmap.md#Contributing)

## Quick start on Minikube
Try steps 1 through 8 below to perform metrics-driven progressive canary rollout of a KFServing model.

**Step 1:** Start Minikube with sufficient resources.
```
minikube start --cpus 4 --memory 12288 --kubernetes-version=v1.17.11 --driver=docker
```

**Step 2:** Install KFServing, iter8-kfserving, and iter8-monitoring. This step uses Kustomize v3, which you can get from [here](https://kubectl.docs.kubernetes.io/installation/kustomize/).
```
curl -L https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/platformsetup.sh | /bin/bash
```

**Step 3:** *In a separate terminal,* setup Minikube tunnel.
```
minikube tunnel --cleanup
```
Enter password if prompted in the above step.

**Step 4:** Create InferenceService object with `default` and `canary` model versions. Wait until it is ready.
```
kubectl create ns kfserving-test
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/common/sklearn-iris.yaml -n kfserving-test
kubectl wait --for condition=ready --timeout=180s inferenceservice/sklearn-iris -n kfserving-test
```

**Step 5:** Send prediction requests to model versions. *In a separate terminal,* from your iter8-kfserving folder, export `SERVICE_HOSTNAME`, `INGRESS_HOST` and `INGRESS_PORT` environment variables, and send prediction requests to the inference service as follows.
```
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kfserving-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
let i=0; while clear; echo "Request $i"; do curl https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/common/input.json | curl -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict -d @-; let i=i+1; sleep 0.5; done
```

**Step 6:** Create the canary rollout experiment.
```
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/experiments/example1.yaml -n kfserving-test
```

**Step 7:** Watch changes to the InferenceService as the canary version succeeds and is progressively rolled out as the new default.
```
kubectl get inferenceservice -n kfserving-test --watch
```

You should see output similar to the following.

```
NAME           URL                                              READY   DEFAULT TRAFFIC   CANARY TRAFFIC   AGE
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    95                5                112s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    95                5                2m47s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    85                15               2m47s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    85                15               3m10s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    75                25               3m11s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    75                25               3m33s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    65                35               3m33s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    65                35               3m55s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    55                45               3m56s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    55                45               3m59s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    100                                4m
sklearn-iris                                                    False                                      4m
sklearn-iris                                                    False                                      4m
sklearn-iris                                                    False                                      4m34s
sklearn-iris                                                    False                                      4m35s
sklearn-iris                                                    False                                      4m35s
sklearn-iris   http://sklearn-iris.kfserving-test.example.com   True    100                                4m36s
```

**Step 8:** *In a separate terminal,* watch the experiment progress.
```
kubectl get experiment -n kfserving-test --watch
```

You should see output similar to the following.

```
kubectl get experiment -n kfserving-test --watch
NAME                        TYPE     TARGET                        COMPLETED ITERATIONS   MESSAGE
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   0                      ExperimentInitialized: Late initialization complete
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   1                      IterationUpdate: Completed Iteration 1
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   2                      IterationUpdate: Completed Iteration 2
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   3                      IterationUpdate: Completed Iteration 3
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   4                      IterationUpdate: Completed Iteration 4
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   5                      IterationUpdate: Completed Iteration 5
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   6                      IterationUpdate: Completed Iteration 6
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   7                      IterationUpdate: Completed Iteration 7
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   8                      IterationUpdate: Completed Iteration 8
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   9                      IterationUpdate: Completed Iteration 9
sklearn-iris-experiment-1   Canary   kfserving-test/sklearn-iris   10                     ExperimentCompleted: Experiment completed successfully
```

At the end of the experiment, if you inspect the InferenceService object (`kubectl get inferenceservice -n kfserving-test -o yaml`), you will notice that `flowers-2` (canary version) has been **promoted** as the new default, all traffic flows to `flowers-2`, and there is no longer a canary section in the InferenceService object.