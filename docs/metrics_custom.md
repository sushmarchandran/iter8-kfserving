# Defining a Custom Metric

> Easily define custom iter8 metrics using metrics in Prometheus.

We illustrate custom metric creation using three examples. The first two examples illustrate `counter` metrics while the third illustrates `gauge` metrics.

### Example 1: Defining a counter metric
Suppose you have a Prometheus counter metric named `correct_predictions`, which records the number of correct predictions made by each model version until now.
```shell
# Prometheus query to get the number of correct predictions by `default` version in the past 30 seconds
sum(increase(correct_predictions{version='default'}[30s]))
```
```shell
# Prometheus query to get the number of correct predictions by `canary` version in the past 30 seconds
sum(increase(correct_predictions{version='canary'}[30s]))
```

You can turn this into an iter8 counter metric using the following yaml manifest.
```yaml
#correctpredictions.yaml
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:
  name: correct-predictions
spec:
  params:
    query: sum(increase(correct_predictions{version='$name'}[$interval])) or on() vector(0)
  description: Number of correct predictions
  type: counter
  provider: prometheus
```

> **Note:** values may be unavailable for a metric in Prometheus, in which case, Prometheus may return a `nodata` response. For example, values may be unavailable for the `correct_predictions` metric for a model version if no requests have been sent to that model version until now, or if Prometheus has a large scrape interval. In such cases, the `on() or vector(0)` clause replaces the `nodata` response with a zero value. This is the recommended approach for creating iter8 counter metrics.


Using the yaml file defined above, you can create an iter8 metric in your Kubernetes cluster as follows.
```shell
kubectl apply -f correctpredictions.yaml -n your-metrics-namespace
```

You can now list this metric using `kubectl` and [use this metric in experiments](usingmetrics.md).
```shell
kubectl get metrics.iter8.tools correct-predictions -n your-metrics-namespace
NAMESPACE      NAME                           TYPE      DESCRIPTION
iter8-system   correct-predictions            counter   Number of correct predictions
```

#### Instantiation of templated HTTP query params
Iter8 instantiates the templated HTTP query params (`spec.params`) before querying Prometheus in each iteration of the experiment. While instantiating the templated params, iter8 will substitute the template variable `$name` with the values `default` or `canary` for the two model versions; iter8 will also substitute the template variable `$interval` with the time elapsed since the start of the experiment (e.g., `80s` or `200s`). 

More concretely, the following Python (pseudo) code snippet provides an approximate behind-the-scenes view of how iter8 instantiates the templated parameters and queries the metrics database.
```python
# Python (pseudo) code snippet intended to illustrate how iter8 queries a metrics database.
metrics_database_url = "https://prometheus.iter8-monitoring:9090/api/v1/query"
instantiated_params = substitute_template_variables(spec.params)
# Here is how instantiated_params might look at this point.
# instantiated_params = {'query': 'sum(increase(correct_predictions{version='default'}[180s])) or on() vector(0)'}
# Using requests library API for HTTP GET
result = requests.get(metrics_database_url, params = instantiated_params).json()
```

### Example 2: `request-count` metric
The `request-count` metric is an [out-of-the-box iter8 metric](../install/iter8-monitoring/metrics/revision-metrics.yaml). Although not a custom metric, this example serves to further illustrate the concepts introduced in Example 1. There is no real difference between custom and out-of-the-box metrics other than the fact the latter is shipped as part of iter8-kfserving and installed by default.
```yaml
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

> Note: i) Example 1 uses `correct_predictions` Prometheus metric while Example 2 uses `revision_app_request_latencies_count`; ii) Example 1 uses a label called `version` to distinguish between model versions while Example 2 uses a label called `service_name`; iii) Example 1 uses exact equality in its filter while Example 2 uses regex matching.

### Example 3: Defining a gauge metric
We can build on Examples 1 and 2 to define a new iter8 gauge metric called `accuracy`. This metric is intended to capture the ratio of correct predictions over request count.
```yaml
#accuracy.yaml
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:
  name: accuracy
spec:
  description: Accuracy of the model version
  params:
    query: (sum(increase(correct_predictions{version='$name'}[$interval])) or on() vector(0)) / (sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0))
  type: gauge
  sample_size: 
    name: request-count
  provider: prometheus
  ```

The `spec.sample_size` field represents the number of data points over which the gauge metric value is computed. In this case, since `accuracy` is computed over all the requests received by a specific model version, the sample_size metric is `request-count`.

