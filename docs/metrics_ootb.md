# Out-of-the-box Metrics

> Iter8-kfserving ships with five out-of-the-box metrics. You can extend the set of available metrics by [defining custom metrics](metrics_custom.md).

Metrics shipped out-of-the-box with iter8-kfserving are described in the following table.

* Each metric is defined at a per-version level. For example, the `request-count` metric measures the number of requests to a model version; the `mean-latency` metric measures the mean latency of a model version. 
* Metrics can be of type `counter` or `gauge`. The value of a counter metric never decreases over time. The two metric types are inspired by [Prometheus metric types](https://prometheus.io/docs/concepts/metric_types/#counter).

|Name   |Description    |Type   |Units  |
|---    |----           |---    |---    |
|request-count  | Number of requests      | counter   |    |
|mean-latency   | Mean latency    | gauge      | milliseconds |
|95th-percentile-tail-latency   | 95th percentile tail latency    | gauge      | milliseconds |
|error-count   | Number of error responses    | counter      |  |
|error-rate   | Fraction of requests with error responses    | gauge      |  |

An overview of iter8 metric resource objects is [here](metricsanatomy.md). Documentation on how to use metrics within experiments is [here](usingmetrics.md). Fields in an iter8 metric resource object `spec` are documented [here](metricscrd.md).
