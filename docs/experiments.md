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
|95th-percentile-tail-latency   | 95th percentile tail latency    | gauge      | milliseconds |
|error-count   | Number of error responses    | counter      |  |
|error-rate   | Fraction of requests with error responses    | gauge      |  |
|container-throttled-seconds-total   | Total time duration the container has been throttled    | counter      | seconds |
|container-cpu-load-average-10s   | Value of container cpu load average over the last 10 seconds    | gauge      | |
|container-fs-io-time-seconds-total   | Cumulative count of seconds spent doing I/Os    | counter      | seconds |
|container-memory-usage-bytes   | Current memory usage, including all memory regardless of when it was    | gauge      | bytes |
|container-memory-failcnt   | Number of times memory usage hit resource limit    | counter      | |
|container-network-receive-errors-total   | Cumulative count of errors encountered while receiving    | counter      | |
|container-network-transmit-errors-total   | Cumulative count of errors encountered while transmitting    | counter      | |
|container-processes   | Number of processes running inside the container    | gauge      | |
|container-tasks-state   | Number of tasks in given state (sleeping, running, stopped, uninterruptible, or ioawaiting)    | gauge      | |