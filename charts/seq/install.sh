#!/usr/bin/bash
set -eux

if [[ $SEQ_INSTALL == true ]]
then
  echo "SEQ_VERSION: $SEQ_VERSION"
  helm upgrade --install seq charts/seq/src/seq -f charts/seq/values.yaml --namespace observability --create-namespace
fi
