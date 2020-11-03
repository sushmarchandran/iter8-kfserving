# Iter8-kfserving experiments and metrics

[KFServing](https://github.com/kubeflow/kfserving) enables serverless inferencing on [Kubernetes](https://kubernetes.io) and [OpenShift](https://www.openshift.com). [Iter8](https://iter8.tools) enables metrics-driven release automation for Kubernetes and OpenShift applications. This package brings the two projects together and enables metrics-driven release automation of KFServing models on Kubernetes and OpenShift.

## Experimentation strategies

### Basic strategies

### Customization

## Metrics

Iter8-kfserving package ships with x "out-of-the-box" metrics, which are described in the following table. You can extend this set by defining custom metrics. Each metric is defined at a per-version level. For example, the `request-count` metric measures the number of requests to a model version; the `mean-latency` metric measures the mean latency of a model version. Metrics can be of type `counter` or `gauge`. They are inspired by [Prometheus counter metric type](https://prometheus.io/docs/concepts/metric_types/#counter) and [Prometheus gauge metric type](https://prometheus.io/docs/concepts/metric_types/#gauge).

|Name   |Description    |Type   |Units  |
|---    |----           |---    |---    |
|request-count  | Number of requests      | counter   |    |
|mean-latency   | Mean latency    | gauge      | milliseconds |
