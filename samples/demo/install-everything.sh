set -e 

mkdir .tmp

cd .tmp

git clone https://github.com/kubeflow/kfserving.git

cd kfserving

./hack/quick_install.sh

kubectl create ns knative-monitoring

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.18.0/monitoring-metrics-prometheus.yaml

cd ../../

kubectl create ns iter8-kfserving

kubectl apply -k kustomize/metrics -n iter8-kfserving