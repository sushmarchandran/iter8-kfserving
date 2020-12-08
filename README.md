# Iter8-kfserving
> [KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics-driven live experiments, release engineering and rollout optimization for Kubernetes and OpenShift applications. The iter8-kfserving package brings the two projects together.

The picture below illustrates an automated canary rollout orchestrated by iter8-kfserving.

![Automated canary rollout orchestrated by iter8-kfserving](docs/images/iter8kfservingquickstart.png)


## Table of Contents
- [Quick start on Minikube](#Quick-start-on-Minikube)
- [Installation](./docs/installation.md)
  * [on Kubernetes Clusters](./docs/kubernetes.md)
  <!-- * [on OpenShift Clusters](./docs/openshift.md) -->
  * on OpenShift Clusters
- [Anatomy of an Experiment](./docs/anatomy.md)
- [Live Experimentation Strategies](./docs/strategy.md)
  * [Online Model Validation Strategies](./docs/validation.md)
    + [Canary](./docs/canary.md)
    <!-- + [A/B](./docs/ab.md)
    + [A/B/n](./docs/abn.md)
    + [BlueGreen](./docs/bluegreen.md) -->
    + A/B
    + A/B/n
    + BlueGreen
  <!-- * [Strategies for Detecting Performance Degradation](./docs/performance.md)
    + [Performance Test](./docs/performancetest.md)
    + [Concept Drift Detection](./docs/conceptdrift.md)
    + [Data Drift Detection](./docs/datadrift.md)
  * [Multi-model Strategies](./docs/multimodel.md)
    + [Ensemble](./docs/ensemble.md)
    + [Personalization](./docs/personalization.md)
    + [Pareto Front](./docs/pareto.md) -->
  * Strategies for Detecting Performance Degradation
    + Performance Test
    + Concept Drift Detection
    + Data Drift Detection
  * Multi-model Strategies
    + Ensemble
    + Personalization
    + Pareto Front
- [Fixed Split Experiments](./docs/fixed.md)
- [Experiment Criteria](./docs/criteria.md)
  * [Objectives](./docs/objectives.md)
  <!-- * [Rewards](./docs/rewards.md) -->
  * Rewards
  * [Indicators](./docs/indicators.md)
- [Concurrent Experiments](./docs/concurrency.md)
- [Explainability](./docs/explanation.md)
  * [Winner Assessment](./docs/winner.md)
  * [Version Assessment](./docs/version.md)
  <!-- * [Objective Details](./docs/objectives.md)
  * [Reward and Improvement Details](./docs/reward.md)
  * [Indicator Details](./docs/indicators.md) -->
  * Objective Details
  * Reward and Improvement Details
  * Indicator Details
<!-- - [Continuous Integration/Deployment/Training](./docs/cicdct.md)
  * [HelmOps Samples](./docs/helm-test.md)
  * [GitOps Samples](./docs/gitops.md)
  * [Kustomize Samples](./docs/kustomize.md)
  * [Pipeline Samples](./docs/pipelinetools.md)
    + [KubeFlow Pipelines](./docs/kfpipelines.md)
    + [GitHub Actions](./docs/githubactions.md)
    + [Tekton](./docs/tekton.md)
    + [Argo CD](./docs/argocd.md)
    + [Circle CI](./docs/circleci.md)
    + [Gitlab](./docs/gitlab.md)
    + [Jenkins-X](./docs/jenkins-x.md)
    + [TravisCI](./docs/travisci.md)
  * [Notifications](./docs/notifications.md)
    + [Webhooks](./docs/webhooks.md)
    + [Slack](./docs/slack.md)
- [Telemetry](./docs/telemetry.md)
    + [Prometheus](./docs/prometheus.md)
    + [OpenMetrics](./docs/openmetrics.md)
    + [Elastic](./docs/elastic.md)
    + [Datadog](./docs/datadog.md)
    + [Jaeger](./docs/jaeger.md) -->
- Continuous Integration/Deployment/Training
  * HelmOps Samples
  * GitOps Samples
  * Kustomize Samples
  * Pipeline Samples
    + KubeFlow Pipelines
    + GitHub Actions
    + Tekton
    + Argo CD
    + Circle CI
    + Gitlab
    + Jenkins-X
    + TravisCI
  * Notifications
    + Webhooks
    + Slack
- Telemetry
    + Prometheus
    + OpenMetrics
    + Elastic
    + Datadog
    + Jaeger
- [Reference](./docs/reference.md)
  * [Experiment CRD](./docs/experiment-crd.md)
  * [Metrics CRD](./docs/metrics-crd.md)
  * [Out-of-the-box Metrics](./docs/metrics-crd.md)
    + [System Metrics](./docs/system-metrics.md)
    <!-- + [ML Metrics](./docs/ml-metrics.md)
    + [Business Metrics](./docs/business-metrics.md) -->
    + ML Metrics
    + Business Metrics
  * [Custom Metrics](./docs/custom-metrics.md)
  <!-- * [Classical and Contextual Multi-armed Bandit Algorithms](./docs/mab.md)
    + [Progressive Rollout Algorithms](rolloutalgos.md)
      - [Constrained Epsilon Greedy](epsilon.md)
      - [Posterior Bayesian Routing](pbr.md)
    + [Ensembling Algorithms](ensemblealgos.md)
    + [Personalization Algorithms](personalizationalgos.md)
    + [Pareto Exploration Algorithms](paretoalgos.md)
  * [Online Bayesian Learning and Estimation Algorithms](./docs/bayesian.md)
    + [Posterior Probability of Winning](posterior.md)
    + [Credible Intervals](credible.md)
    + [Bayesian Hypothesis Testing](hypothesistests.md)
    + [Bayes Risk](risk.md)
  * [Analytics Customization](./docs/analytics-customization.md) -->
  * Classical and Contextual Multi-armed Bandit Algorithms
    + Progressive Rollout Algorithms
      - Constrained Epsilon Greedy
      - Posterior Bayesian Routing
    + Ensembling Algorithms
    + Personalization Algorithms
    + Pareto Exploration Algorithms
  * Online Bayesian Learning and Estimation Algorithms
    + Posterior Probability of Winning
    + Credible Intervals
    + Bayesian Hypothesis Testing
    + Bayes Risk
  * Analytics Customization
- [Roadmap](./docs/roadmap.md)
- [Contributing](./docs/contributing.md)

## Quick start on Minikube
Steps 1 through 10 below enable you to perform automated canary rollout of a KFServing model using latency and error-rate metrics collected in a Prometheus backend. Metrics definition and collection is enabled by the KNative monitoring and iter8-kfserving components installed in Step 3 below.

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
kubectl apply -f samples/experiments/example1.yaml -n kfserving-test
```

**Step 10:** Watch as the canary version succeeds and gets promoted as the new default.
```
kubectl get inferenceservice -n kfserving-test --watch
```