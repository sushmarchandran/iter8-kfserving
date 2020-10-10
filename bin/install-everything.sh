set -e 

mkdir .tmp

cd .tmp

git clone https://github.com/kubeflow/kfserving.git

cd kfserving

./hack/quick_install.sh

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.18.0/monitoring-metrics-prometheus.yaml