#!/usr/bin/bash
set -eu

if (($MASTER_INDEX == 0)); then
  echo "Skip, main master has already initialized"
else
  echo "Join $(hostname) to Cluster"
  sudo bash /tmp/kubeadm_control_plane_join
  sudo systemctl enable kubelet
fi