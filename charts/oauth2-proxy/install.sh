#!/usr/bin/bash
set -eux

if [[ $OAUTH2_PROXY_INSTALL == true ]]
then
  echo "OAUTH2_PROXY_VERSION: $OAUTH2_PROXY_VERSION"
  helm upgrade --install oauth2-proxy charts/oauth2-proxy/src/oauth2-proxy -f charts/oauth2-proxy/values.yaml --namespace oauth2-proxy --create-namespace
fi