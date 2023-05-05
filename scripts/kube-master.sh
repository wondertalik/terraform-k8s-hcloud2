#!/usr/bin/bash
set -eu

if (($MASTER_INDEX == 0)); then
  echo "Skip, main master has already initialized"
else
  echo "Join $(hostname) to Cluster"
  
  NODE_PRIVATE_IP=$(ip -4 -o a show ens10 | awk '{print $4}' | cut -d/ -f1)
  echo "MASTER_NODE_PRIVATE_IP: $NODE_PRIVATE_IP"
  echo "$(cat /tmp/kubeadm_control_plane_join) --apiserver-advertise-address $NODE_PRIVATE_IP --v=5" > /tmp/kubeadm_control_plane_join
  
  sudo bash /tmp/kubeadm_control_plane_join
  sudo systemctl enable kubelet
fi