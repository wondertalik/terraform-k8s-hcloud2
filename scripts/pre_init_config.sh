#!/bin/bash
set -eux

mkdir -p /etc/systemd/system/kubelet.service.d
NODE_PRIVATE_IP=$(ip -4 -o a show ens10 | awk '{print $4}' | cut -d/ -f1)
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/20-hcloud.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external --node-ip=$NODE_PRIVATE_IP"
EOF