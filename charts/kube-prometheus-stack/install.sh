#!/usr/bin/bash

set -eux

helm upgrade --install kube-prometheus-stack charts/kube-prometheus-stack/src/kube-prometheus-stack \
    -f charts/kube-prometheus-stack/values.yaml --namespace monitoring --create-namespace