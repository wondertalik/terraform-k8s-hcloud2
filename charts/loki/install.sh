#!/usr/bin/bash

set -eux

if [[ $LOKI_INSTALL == true ]]
then
  echo "LOKI_VERSION: $LOKI_VERSION"
  helm upgrade --install loki charts/loki/src/loki -f charts/loki/values.yaml --namespace monitoring --create-namespace
fi
