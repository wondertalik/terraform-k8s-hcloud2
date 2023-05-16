#!/usr/bin/bash
set -eux

#install cilium from charts directory
echo "CILIUM_VERSION: $CILIUM_VERSION"
helm upgrade --install cilium charts/cilium/src/cilium -f charts/cilium/values.yaml \
   --namespace kube-system \
   --set operator.replicas=$MASTER_COUNT \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true \
   --set hubble.ui.ingress.enabled=$RELAY_UI_ENABLED
   # --set tunnel=disabled \
   # --set ipv4NativeRoutingCIDR=$POD_NETWORK_CIDR \
   # --set ipam.mode=kubernetes

kubectl -n kube-system patch ds cilium --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

# install cilium cli tools
ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/v0.14.1/cilium-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${ARCH}.tar.gz{,.sha256sum}

#install hubble cli
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/v0.11.3/hubble-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${ARCH}.tar.gz{,.sha256sum}
