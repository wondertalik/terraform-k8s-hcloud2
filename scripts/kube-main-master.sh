#!/usr/bin/bash
set -eu

sudo kubeadm init --pod-network-cidr="$POD_NETWORK_CIDR" --control-plane-endpoint=$CONTROL_PLANE_ENDPOINT:6443 --cri-socket unix:///run/containerd/containerd.sock --upload-certs --apiserver-advertise-address $APISERVER_ADVERTISE_ADDRESS --apiserver-cert-extra-sans $APISERVER_CERT_EXTRA_SANS --v=5

# used to join nodes to the cluster
sudo mkdir -p /tmp/kubeadm
sudo chown -R $SSH_USERNAME:$SSH_USERNAME /tmp/kubeadm
sudo kubeadm token create --print-join-command > /tmp/kubeadm/kubeadm_join

sudo kubeadm init phase upload-certs --upload-certs > /tmp/cert.key
export CERT_KEY="$(tail -1 /tmp/cert.key)"
sudo kubeadm token create --print-join-command --certificate-key $CERT_KEY > /tmp/kubeadm/kubeadm_control_plane_join
sudo cp -i /etc/kubernetes/admin.conf /tmp/kubeadm/kubeadm_config
sudo chown -R $SSH_USERNAME:$SSH_USERNAME /tmp/kubeadm/kubeadm_config

sudo systemctl enable kubelet