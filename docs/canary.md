## Progressive Canary Release Experiment
> Use iter8's canary experiments to progressively rollout a new model version in production. Iter8 assesses your versions based on the objectives specified in the experiment and uses this assessment to automatically rollout the `winning version` in a safe and statistically robust manner.

For an overview of iter8 experiments, see [anatomy of an iter8 experiment](experimentanatomy.md).

### Rules for determining the `winner` in a canary release experiment
1. If `canary` satisfies all `objectives`, then `canary` is the winner.
2. If `default` satisfies all `objectives` and `canary` does not, then `default` is the winner.
3. If neither versions satisfy all `objectives`, then there is no winner.

### Traffic shifting
The typical traffic shifting behavior during a canary release experiment is as follows. 
1. All traffic flows to `default` at the beginning of the experiment. 
2. If `canary` is the winner, traffic progressively shifts towards `canary` during the experiment; `canary` is promoted at the end of the experiment, and all traffic flows to `canary`. 
3. If `default` is the winner or if there is no winner, traffic is mostly concentrated on `default` during the experiment; there is a `rollback` at the end of the experiment and all traffic flows to `default`.

### Example
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

In the above example, `target` is the InferenceService object named `sklearn-iris` in the `kfserving-test` namespace. 
1. If the `mean-latency` of `canary` is within 1000 (milliseconds), and if its `error-rate` is within 1%, then `canary` is the winner. 
2. If `canary` fails to satisfy these objectives, but `default` does, then `default` is the winner.
3. If neither versions satisfy the objectives, then there is no winner.

Notice the `indicators` section within `criteria`. This section does not affect iter8's winner assessment or traffic recommendation. However, metrics specified in this section are recorded as part of `status.analysis` section of the Experiment resource object and can be [described using `iter8ctl`](iter8ctl.md).

The three metrics used in this example are shipped [out-of-the-box](metrics_ootb.md). You can also [define custom metrics](metrics_custom.md) and [use them in experiments](usingmetrics.md).