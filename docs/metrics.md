# Iter8 Metrics

## Metrics defined by iter8

By default, iter8 leverages some of the metrics stored in Prometheus. This list is available [here](experiments.md#metrics). Users relying on iter8's out-of-the-box metrics can simply reference them in the _criteria_ section of an _experiment_ specification. Description of the _experiment_ CRD is Coming Soon!

During an `experiment`, for every call made from  _controller_ to _analytics_ service, the latter in turn calls Prometheus to retrieve values of the metrics referenced by the Kubernetes `experiment` resource. _Iter8-analytics_ analyzes the service versions that are a part of the experiment and arrives at an assessment based on their metric values. It returns this assessment to _controller_.


## Adding a new Metric

When iter8 is installed, the out-of-the-box metrics available [here](../install/metrics)
is directly available to be used in _iter8-experiments_. You can extend this set by defining custom metrics. Some of the details needed to create a custom metric are described below using a sample metric CR:

```
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:

  # Name of the custom metric
  name: container-memory-usage-bytes
spec:
  params:

    # Iter8 uses a query template template to query Prometheus and compute the value of the metric for every service version. Currently, iter8 supports Prometheus as a backend database to observe metrics. Please refer to the Prometheus Query Template section to learn more.
    query: container_memory_usage_bytes{container='kfserving-container', id=~'/kubepods.*', pod=~'.*$name.*'}
  
  # An optional description can be added to the metric CR
  description: Current memory usage, including all memory regardless of when it was accessed

  # an optional string that is used to define the unit of the metric
  units: bytes

  # Iter8 metrics can be of two types: if the metric defined is a couter (i.e., its value never decreases over time) then its type is 'counter', otherwise it is 'gauge' 
  type: gauge

  # Currently, iter8 supports Prometheus as a backend metrics provider. Other backend support is coming soon!
  provider: prometheus
```

### Prometheus query template

A sample query template is shown below:

```
sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0)
```

As shown above, the query template has two placeholders (i.e., terms beginning with $). These placeholders are substituted with actual values by _iter8-analytics_ in order to construct a Prometheus query.
1) The `$name` placeholder is replaced by the name of the service participating in the experiment. _Iter8-analytics_ queries Prometheus with different values for this placeholder based on the type of the experiment- once for the baseline version and once for each of the candidate versions (if any)- using this placeholder.
2) The time period of aggregation is captured by the placeholder `$interval`.

Once the custom metric has been applied, it can be referenced in the `criteria` section of the experiment CRD.