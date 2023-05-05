#!/usr/bin/bash

set -eux

helm upgrade --install promtail charts/promtail/src/promtail -f charts/promtail/values.yaml --namespace monitoring --create-namespace