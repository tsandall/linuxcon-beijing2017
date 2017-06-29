#!/usr/bin/env bash

set -ex

kubectl --context=federation delete --ignore-not-found=true rs cat-pics
kubectl --context=federation delete --ignore-not-found=true rs dooms-day
kubectl --context=federation --namespace kube-federation-scheduling-policy delete --ignore-not-found=true configmap customers
kubectl --context=federation --namespace kube-federation-scheduling-policy delete --ignore-not-found=true configmap example
kubectl --context=federation --namespace kube-federation-scheduling-policy delete --ignore-not-found=true configmap empty
