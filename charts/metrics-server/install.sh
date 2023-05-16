#!/usr/bin/bash
set -eu

echo "METRIC_SERVER_VERSION: $METRIC_SERVER_VERSION"
helm upgrade --install metrics-server charts/metrics-server/src/metrics-server -f charts/metrics-server/values.yaml --set args={--kubelet-insecure-tls} --namespace kube-system