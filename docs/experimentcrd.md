## Experiment Resource Object

Fields in an iter8 experiment resource object `spec` are documented here. Currently, this documentation is limited to the fields use in [this sample](../samples/experiments/example1.yaml). For complete documentation, refer to the iter8 Experiment API implemented [here](https://github.com/iter8-tools/etc3/blob/main/api/v2alpha1/experiment_types.go).

### Spec

| Field | Type | Description | Required |
| ----- | ---- | ----------- | -------- |
| target | string | Reference to an InferenceService object in the `namespace/name` format. | Yes |
| strategy | [Strategy](#strategy) | Strategy used for experimentation. | Yes |
| criteria | [Criteria](#criteria) | Criteria used to evaluate versions. | No |
| duration | Duration | Duration of the experiment. | No |

### Strategy

| Field | Type | Description | Required |
| ----- | ---- | ----------- | -------- |
| type | string | Type of iter8 experiment. Currently, `canary` is the only supported value for the experiment type. | Yes |

### Criteria
> Note: References to metric resource objects within experiment criteria can be in the `namespace/name` format or in the `name` format. If the `name` format is used (i.e., if only the name of the metric is specified), then iter8 first searches for the metric in the namespace of the experiment resource object followed by the `iter8-system` namespace. If iter8 cannot find the metric in either of these namespaces, then the experiment is not considered well-specified and will terminate in a failure.

| Field | Type | Description | Required |
| ----- | ---- | ----------- | -------- |
| objectives | [Objective[]](#objective) | A list of objectives. Satisfying all objectives in an experiment is a necessary condition for a version to be declared a `winner`. | No |
| indicators | string[] | A list of references to Metric objects in the `namespace/name` format or in the `name` format. During the experiment, for each version, indicator metric values are recorded by iter8 in the experiment status section. | No |

#### Objective

| Field | Type | Description | Required |
| ----- | ---- | ----------- | -------- |
| metric | string | Reference to a metric resource object in the `namespace/name` format or in the `name` format.  | Yes |
| upperLimit | [quantity](https://www.k8sref.io/docs/common-definitions/quantity-/) | Upper limit on the metric value. If specified, for a version to satisfy this objective, its metric value needs to be below the limit. | No |
| lowerLimit | [quantity](https://www.k8sref.io/docs/common-definitions/quantity-/) | Lower limit on the metric value. If specified, for a version to satisfy this objective, its metric value needs to be above the limit. | No |

### Duration

| Field | Type | Description | Required |
| ----- | ---- | ----------- | -------- |
| intervalSeconds | int32 | Duration of a single iteration of the experiment in seconds. Default value = 20 seconds. | No |
| maxIterations | int32 | Maximum number of iterations in the experiment. In case of failure, the experiment may be terminated earlier. Default value = 15. | No |


