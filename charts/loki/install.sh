#!/usr/bin/bash

set -eux

if [[ $LOKI_INSTALL == true ]]
then
  helm upgrade --install loki charts/loki/src/loki -f charts/loki/values.yaml --namespace monitoring --create-namespace
fi
