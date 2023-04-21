#!/usr/bin/bash
set -eu

#install cilium from charts directory
helm upgrade --install cilium charts/cilium/src/cilium -f charts/cilium/values.yaml \
   --namespace kube-system    --reuse-values \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true

# install cilium cli tools
ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/v0.13.2/cilium-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${ARCH}.tar.gz{,.sha256sum}

#install hubble cli
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/v0.11.3/hubble-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${ARCH}.tar.gz{,.sha256sum}
