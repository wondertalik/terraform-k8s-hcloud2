#!/usr/bin/bash

set -eux

#install The cert-manager Command Line Tool (cmctl)
#https://cert-manager.io/docs/reference/cmctl/#installation
ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cert-manager/cert-manager/releases/latest/download/cmctl-linux-$ARCH.tar.gz
sudo tar xzvfC cmctl-linux-${ARCH}.tar.gz /usr/local/bin
rm cmctl-linux-${ARCH}.tar.gz

echo "CERT_MANAGER_VERSION: $CERT_MANAGER_VERSION"
helm upgrade --install cert-manager charts/cert-manager/src/cert-manager -f charts/cert-manager/values.yaml \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

cat <<EOF | sudo tee letsencrypt-prod.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: $ACME_EMAIL
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

kubectl apply -f letsencrypt-prod.yaml

cat <<EOF | sudo tee letsencrypt-staging.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: $ACME_EMAIL
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

kubectl apply -f letsencrypt-staging.yaml