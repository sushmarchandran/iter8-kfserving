## Metric Resource Object

Fields in an iter8 metric resource object `spec` are documented here.

| Field | Type         | Description | Required |
| ----- | ------------ | ----------- | -------- |
| params | map[string][string] | Templated HTTP query parameters. Each key in this map represents a parameter name; the corresponding value is a template, which will be instantiated by iter8 while querying the metrics backend. For examples and more details, see [here](metrics_custom.md#instantiation-of-templated-http-query-params).| No |
| description | string | Human-readable description of the metric. | No |
| units | string | Units of measurement. Units are used for display purposes. | No |
| type | string | Metric type. Valid values are `counter` and `gauge`. Default value = `gauge`. | No |
| sampleSize | string | Reference to a metric object in the `namespace/name` format or in the `name` format. The value of the sampleSize metric represents the number of data points over which the metric value is computed. This field applies only to `gauge` metrics. | No |
| provider | string | Type of the metrics database. Currently, `prometheus` is the only valid value. | No |