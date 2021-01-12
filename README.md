# Iter8-kfserving
> Iter8-kfserving enables metrics-driven live experiments, progressive delivery, and automated rollouts for ML models in production over Kubernetes and OpenShift clusters.

The picture below illustrates progressive canary release of a KFServing model using iter8-kfserving.

![Progressive canary rollout orchestrated by iter8-kfserving](docs/images/quickstart.png)

## Table of Contents
- [Quick start on Minikube](#Quick-start-on-Minikube)
- [Installation](./docs/installation.md)
- [Anatomy of an iter8 experiment](./docs/experimentanatomy.md)
- [Progressive canary release experiment](./docs/canary.md)
- [Describe experiments using iter8ctl](./docs/iter8ctl.md)
- Iter8 metrics
  * [Using metrics in experiments](./docs/usingmetrics.md)
  * [Out-of-the-box metrics](./docs/metrics_ootb.md)
  * [Anatomy of iter8 metrics](./docs/metricsanatomy.md)
  * [Defining a custom metric](./docs/metrics_custom.md)
- [Concurrent experiments](./docs/concurrency.md)
- Reference
  * [Experiment resource object](./docs/experimentcrd.md)
  * [Metric resource object](./docs/metricscrd.md)
- [Wiki with roadmap and developer documentation](https://github.com/iter8-tools/iter8-kfserving/wiki)
- [Contributing](./docs/contributing.md)

## Quick start on Minikube
Steps 1 to 7 demonstrate metrics-driven progressive canary release of a KFServing model using iter8-kfserving. 

To run steps 1 to 6, you need [Minikube](https://minikube.sigs.k8s.io/docs/start/) and [Kustomize v3](https://kubectl.docs.kubernetes.io/installation/kustomize/). To run step 7, you need [Go 1.13+](https://golang.org/doc/install).

**Step 1:** Start Minikube with sufficient resources.
```shell
minikube start --cpus 4 --memory 12288 --kubernetes-version=v1.17.11 --driver=docker
```

**Step 2:** Install KFServing, kfserving-monitoring, and iter8-kfserving. This step requires `kubectl` and [Kustomize v3](https://kubectl.docs.kubernetes.io/installation/kustomize/).
```shell
curl -L https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/platformsetup.sh | /bin/bash
```

**Step 3:** *In a separate terminal,* setup Minikube tunnel. If prompted, enter password.
```shell
minikube tunnel --cleanup
```

**Step 4:** Create an InferenceService object with an initial `default` model. Update it with a `canary` model. This step takes a couple of minutes to complete.
```shell
curl -L https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/inferenceservicesetup.sh | /bin/bash
```

**Step 5:** *In a separate terminal,* send prediction requests to model versions.
```shell
curl -L https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/predictionrequests.sh | /bin/bash
```

**Step 6:** Create the iter8-kfserving canary experiment.
```shell
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/samples/quickstart/experiment.yaml
```

**Step 7:** *In a separate terminal,* periodically describe the experiment.

**Install** [iter8ctl](https://github.com/iter8-tools/iter8ctl). You can change the directory where `iter8ctl` binary is installed by changing GOBIN below.
```shell
GOBIN=/usr/local/bin go get github.com/iter8-tools/iter8ctl@v0.1-alpha
```

Periodically describe the experiment.
```
while clear; do
  kubectl get experiment experiment-1 -o yaml | iter8ctl describe -f -
  sleep 15
done
```

You should see output similar to the following.
```shell
******
Experiment name: experiment-1
Experiment namespace: default
Experiment target: default/my-model

******
Number of completed iterations: 10

******
Winning version: canary

******
Objectives
+--------------------------+---------+--------+
|        OBJECTIVE         | DEFAULT | CANARY |
+--------------------------+---------+--------+
| mean-latency <= 1000.000 | true    | true   |
+--------------------------+---------+--------+
| error-rate <= 0.010      | true    | true   |
+--------------------------+---------+--------+

******
Metrics
+--------------------------------+---------+---------+
|             METRIC             | DEFAULT | CANARY  |
+--------------------------------+---------+---------+
| request-count                  | 132.294 |  73.254 |
+--------------------------------+---------+---------+
| 95th-percentile-tail-latency   | 298.582 | 294.597 |
| (milliseconds)                 |         |         |
+--------------------------------+---------+---------+
| mean-latency (milliseconds)    | 229.529 | 230.090 |
+--------------------------------+---------+---------+
| error-rate                     |   0.000 |   0.000 |
+--------------------------------+---------+---------+
```

The experiment should complete after 12 iterations (~3 mins). Once the experiment completes, inspect the InferenceService object. 
```shell
kubectl get isvc/my-model
```

You should see 100% of the traffic shifted to the canary model, similar to the below output.
```
# output of the above command should be similar to the below
NAME       URL                                   READY   PREV   LATEST   PREVROLLEDOUTREVISION   LATESTREADYREVISION                AGE
my-model   http://my-model.default.example.com   True           100                              my-model-predictor-default-zwjbq   5m
```
