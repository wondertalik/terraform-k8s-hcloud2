#!/usr/bin/bash
set -eu

echo "Join node $(hostname) to Cluster"
sudo bash /tmp/kubeadm_join
sudo systemctl enable kubelet