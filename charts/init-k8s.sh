#!/usr/bin/bash
set -eu

#install cilium from charts directory
helm upgrade --install cilium charts/cilium/src/cilium -f charts/cilium/values.yaml --namespace kube-system

# install vlidation cli tools
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

#create secrets hcloud in k8s
kubectl -n kube-system create secret generic hcloud --from-literal=token=$K8S_HCLOUD_TOKEN --from-literal=network=$PRIVATE_NETWORK_ID

#install hcloud-controller-manager
helm upgrade --install hccm charts/hccm/src/hcloud-cloud-controller-manager -f charts/hccm/values.yaml --namespace kube-system --set networking.clusterCIDR=$POD_NETWORK_CIDR