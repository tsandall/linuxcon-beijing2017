#!/usr/bin/env bash

source util.sh

# Init
set -ex
kubectl config use-context federation
kubectl label --overwrite cluster europe-on-prem on-prem=true
kubectl -n kube-federation-scheduling-policy create configmap empty --from-file=empty.rego || true
kubectl -n kube-federation-scheduling-policy create configmap example --from-file=example.rego
kubectl -n kube-federation-scheduling-policy create configmap customers --from-file=customers.rego
set +ex

read -s
clear

# Demo

run "kubectl get clusters"

# Clusters can be labelled or annotated to indicate their capabilities. In this
# case we label clusters to indicate whether they are "on-premise".
run "kubectl get clusters europe-on-prem -o json | jq .metadata"

run "view customers.rego"

# Deploy low criticality workload.
run "kubectl create -f cat-pics.yaml"

# Inspect annotations applied by policy.
run "kubectl get rs cat-pics -o json | jq .metadata"

# TODO inspect individual clusters to see correct placement

run "view example.rego"

# Deploy normal workload (which implies on-premise requirement.)
run "kubectl create -f dooms-day.yaml"

# TODO inspect individual clusters to see correct placement

#  Inspect annotations applied by policy.
run "kubectl get rs dooms-day -o json | jq .metadata"
