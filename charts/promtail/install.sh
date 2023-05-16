#!/usr/bin/bash

set -eux

if [[ $PROMTAIL_INSTALL == true ]]
then
  echo "PROMTAIL_VERSION: $PROMTAIL_VERSION"
  helm upgrade --install promtail charts/promtail/src/promtail -f charts/promtail/values.yaml --namespace monitoring --create-namespace
fi