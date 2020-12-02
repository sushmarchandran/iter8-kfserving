# Custom iter8 Metrics

When iter8 is installed, the [out-of-the-box metrics](metrics_ootb.md) are directly available to be used in _iter8-experiments_. You can extend this set with custom metrics by creating a valid CR. Some of the details needed to create a custom metric are described below using a sample metric CR:

```
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:

  # Name of the custom metric
  name: mean-latency
spec:
  params:

    # Iter8 uses a query template template to query Prometheus and compute the value of the metric for every service version. Currently, iter8 supports Prometheus as a backend database to observe metrics. Please refer to the Prometheus Query Template section below to learn more.
    query: (sum(increase(revision_app_request_latencies_sum{service_name=~'.*$name'}[$interval]))or on() vector(0)) / (sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0))
  
  # An metric description; optional
  description: Mean latency

  # a string denoting the unit of the metric defined; optional
  units: milliseconds

  # Iter8 metrics can be of two types: if the metric defined is a counter (i.e., its value never decreases over time) then its type is 'counter', otherwise it is 'gauge' 
  type: gauge

  # measures the number of requests to a model version over which this metric is measured; optional
  sample_size: 
    name: request-count

  # Currently, iter8 supports Prometheus as a backend metrics provider. Other backend support is coming soon!
  provider: prometheus
```


#### Sample Counter metric CR
```
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:
  name: request-count
spec:
  params:
    query: sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0)
  description: Number of requests
  type: counter
  provider: prometheus
```

#### Sample Gauge metric CR
```
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:
  name: mean-latency
spec:
  description: Mean latency
  units: milliseconds
  params:
    query: (sum(increase(revision_app_request_latencies_sum{service_name=~'.*$name'}[$interval]))or on() vector(0)) / (sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0))
  type: gauge
  sample_size: 
    name: request-count
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