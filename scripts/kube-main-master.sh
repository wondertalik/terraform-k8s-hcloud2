#!/usr/bin/bash
set -eux

NODE_PRIVATE_IP=$(ip -4 -o a show ens10 | awk '{print $4}' | cut -d/ -f1)

echo "KUBE_MAIN_NODE_PRIVATE_IP: $NODE_PRIVATE_IP"
echo "
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
localAPIEndpoint:
  advertiseAddress: $NODE_PRIVATE_IP
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
controlPlaneEndpoint: "$CONTROL_PLANE_ENDPOINT:6443"
networking:
  podSubnet: $POD_NETWORK_CIDR
apiServer:
  certSANs:
    - $NODE_PRIVATE_IP
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
etcd:
  local:
    extraArgs:
      listen-metrics-urls: http://0.0.0.0:2381
clusterName: $CLUSTER_NAME
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
metricsBindAddress: 0.0.0.0:10249
" > /tmp/kubeadm.yml

sudo kubeadm init \
    --upload-certs \
    --config /tmp/kubeadm.yml \
    --v=5 

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