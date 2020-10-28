#!/bin/bash

# Check if ITER8_KFSERVING_ROOT env variable is set and act accordingly. 
# Explanation: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash

if [ -z ${var+x} ]; then 
    echo "ITER8_KFSERVING_ROOT env variable is not set"; 
else 
    echo "ITER8_KFSERVING_ROOT env variable is set to '$ITER8_KFSERVING_ROOT'"; 
    kubectl create ns kfserving-test
    kubectl apply -f $ITER8_KFSERVING_ROOT/demo/sklearn-iris.yaml -n kfserving-test
fi

