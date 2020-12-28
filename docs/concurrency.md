## Concurrent Experiments

> This feature is work-in-progress.

Iter8 uses the following rules to determine which experiments are allowed to run in parallel.

1. If two experiments A and B are defined for two distinct InferenceService objects, i.e., A and B have distinct `spec.target` values, iter8 can run them in parallel.

2. If two are more experiments are defined for the same InferenceService object, i.e., they have the same `spec.target` values, then iter8 runs them sequentially. Specifically, suppose A and B are defined for the same InferenceService object, and A has an earlier `creationTimestamp` compared to B; then, iter8 ensures that A is completed before B is started.