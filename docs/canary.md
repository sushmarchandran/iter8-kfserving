## Progressive Canary Release Experiment
> Use iter8's canary release experiments to progressively rollout a new model version in production. Iter8 assesses how your versions perform with respect to the objectives specified in the experiment, and uses this assessment to automatically rollout the `winner` in a safe and statistically robust manner.

We describe how iter8 identifies the `winner` and shifts traffic in a canary release experiment, and provide an example. For a basic overview, see [anatomy of an iter8 experiment](experimentanatomy.md).

### Rules for Determining the `winner` in a Canary Release Experiment
1. If `canary` satisfies all `objectives`, then `canary` is the winner.
2. If `default` satisfies all `objectives` and `canary` does not, then `default` is the winner.
3. If neither versions satisfy all `objectives`, then there is no winner.

### Traffic Shifting
The typical traffic shifting during canary release is as follows. All traffic flows to `default` at the start of the experiment. If `canary` is the winner, traffic progressively shifts towards `canary` during the experiment; `canary` is promoted at the end of the experiment, and all traffic flows to `canary`. When `default` is the winner or when there is no winner, traffic is mostly concentrated on `default` during the experiment; there is a `rollback` at the end of the experiment and `canary` is removed.

### Example
The following is an example of a canary release experiment.

```yaml
apiVersion: iter8.tools/v2alpha1
kind: Experiment
metadata:
  name: sklearn-iris-experiment-1
spec:
  target: kfserving-test/sklearn-iris
  strategy:
    type: Canary
  criteria:
    indicators:
    - 95th-percentile-tail-latency
    objectives:
    - metric: mean-latency
      upperLimit: 1000
    - metric: error-rate
      upperLimit: "0.01"
  duration:
    intervalSeconds: 15
    maxIterations: 10
```

In the above example, `target` is the InferenceService object named `sklearn-iris` in the `kfserving-test` namespace (see its yaml manifest [here](../samples/common/sklearn-iris.yaml)). If the `mean-latency` of `canary` is within 1000 (milli seconds), and if its `error-rate` is within 1%, then `canary` is the winner. If `canary` fails to satisfy these objectives, but `default` does, then `default` is the winner. If neither versions satisfy the objectives, then there is no winner.

Notice the (optional) `indicators` section within `criteria`. Metrics specified in this section are collected for each version during the experiment, and reported as part of the `status.analysis` subsection of the experiment object.

The three metrics used in the this example are shipped [out-of-the-box](metrics_ootb.md). You can also [define custom metrics](metrics_custom.md) and use them in experiments.