#!/usr/bin/bash

set -eux

if [[ $PROMTAIL_INSTALL == true ]]
then
  helm upgrade --install promtail charts/promtail/src/promtail -f charts/promtail/values.yaml --namespace monitoring --create-namespace
fi