#!/usr/bin/bash
set -eu

helm upgrade --install metrics-server charts/metrics-server/src/metrics-server -f charts/metrics-server/values.yaml --set args={--kubelet-insecure-tls} --namespace kube-system