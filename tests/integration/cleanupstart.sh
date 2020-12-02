#!/bin/bash

# Clean up after testing start handler

kubectl delete crd inferenceservices.serving.kubeflow.org
kubectl delete crd experiments.iter8.tools 
kubectl delete crd metrics.iter8.tools
kubectl delete ns iter8-system
kubectl delete ns kfserving-test