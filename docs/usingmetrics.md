## Using Metrics in Experiments

> Iter8 defines a Kubernetes resource type called `Metric`. This means, you can create, list and watch iter8 metric resource objects using the `kubectl` command. You can use any iter8 metric within iter8 experiments as [illustrated here](experimentanatomy.md).

### Finding iter8 metrics
List all iter8 metrics installed in your cluster as follows.
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

### Using iter8 metrics: specify limits on metric values during experiments
You can use the `spec.criteria.objectives` subsection of the experiment spec to specify upper and lower limits on metric values which you would like your versions to satisfy. During the experiment, iter8 will assess each version to determine if it satisfies the objectives, and use this assessment to determine the `winner`. Below is an example of `spec.criteria.objectives`.
```yaml
objectives:
- metric: iter8-system/mean-latency
  upperLimit: 1000
- metric: iter8-system/error-rate
  upperLimit: "0.01"
```

### Using iter8 metrics: report metric values during experiments
You can use the `spec.criteria.indicators` subsection of the Experiment object to specify a list of iter8 metrics. For each of these metrics and for each version, iter8 will report the observed metric value within its `status.analysis` section enabling you to [use `iter8ctl` to describe the experiment](iter8ctl.md) and see indicator values. This is especially useful if you want to know the values of iter8-metrics that you have **not** included within objectives. Below is an example of `spec.criteria.indicators`.
```yaml
indicators:
- iter8-system/95th-percentile-tail-latency
```

### Rules for resolving metric references
Notice the `namespace/name` format for referencing metrics in the above examples. This is the recommended approach.

**If you do not specify a namespace** (for example, you use `metric: mean-latency` within objectives), then iter8 searches for the metric, first in namespace of the experiment resource object, followed by the `iter8-system` namespace. If iter8 does not find the metric in either of these namespaces, the experiment is not considered well-specified and terminates with a failure.