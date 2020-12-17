## Using Metrics in Experiments

### Finding available metrics
Iter8 defines a Kubernetes resource type called [`Metric`](metricscrd.md). Throughout this documentation, the term `iter8-metric` (or `metric`) refers to a Kubernetes resource object of this type. You can list all metrics installed in your cluster as follows.
```shell
kubectl get metrics.iter8.tools --all-namespaces
```

You should see output similar to the following.
```shell
NAMESPACE      NAME                           TYPE      DESCRIPTION
iter8-system   95th-percentile-tail-latency   gauge     95th percentile tail latency
iter8-system   error-count                    counter   Number of error responses
iter8-system   error-rate                     gauge     Fraction of requests with error responses
iter8-system   mean-latency                   gauge     Mean latency
iter8-system   request-count                  counter   Number of requests
```

### Using metrics
Use metrics in experiments by including them under the `spec.criteria.objectives` subsection or under the `spec.criteria.indicators` subsection.

#### Usage within `spec.criteria.objectives`
Objectives are metrics coupled with upper or lower limits. During an experiment, iter8 assesses each version to determine if it satisfies the objectives, and determines a `winner` based on this assessment. Below is an example of `spec.criteria.objectives` subsection.
```yaml
objectives:
- metric: iter8-system/mean-latency
  upperLimit: 1000
- metric: iter8-system/error-rate
  upperLimit: "0.01"
```

#### Usage within `spec.criteria.indicators`
Indicators are simply a list of metrics. During the experiment, iter8 records the observed values of these metrics for each version in the Experiment resource object.
```yaml
indicators:
- iter8-system/95th-percentile-tail-latency
```

Metric values observed for different versions, current version/winner assessments, and current traffic split computed by iter8 are available as part of the `status.analysis` subsection of the [Experiment resource](experimentcrd.md) object.

#### Iter8's rules for resolving metric references
Notice the `namespace/name` format for referencing metrics in the above examples. This is the recommended approach.

If you do not specify a namespace (for example, you use `metric: mean-latency` within objectives), iter8 first searches for the metric within the `iter8-system` namespace, and then searches for it in the namespace of the experiment resource object. If iter8 does not find the metric in either of these namespaces, the experiment is not considered well-specified and terminates with a failure.
