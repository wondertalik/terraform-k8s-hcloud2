#!/usr/bin/bash

set -eux

helm upgrade --install loki charts/loki/src/loki -f charts/loki/values.yaml --namespace monitoring --create-namespace