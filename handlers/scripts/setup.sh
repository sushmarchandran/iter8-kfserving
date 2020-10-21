#!/bin/bash

kubectl get experiment $1 -o yaml > sample.yaml