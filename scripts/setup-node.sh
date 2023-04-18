#!/bin/bash

timedatectl set-ntp 1
sudo timedatectl set-timezone Europe/Andorra

CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi

wget https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-${CLI_ARCH}.tar.gz
tar Cxzvf /usr/local containerd-1.7.0-linux-${CLI_ARCH}.tar.gz

mkdir -p /usr/local/lib/systemd/system

tee -a /usr/local/lib/systemd/system/containerd.service <<END
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
#uncomment to enable the experimental sbservice (sandboxed) version of containerd/cri integration
#Environment="ENABLE_CRI_SANDBOXES=sandboxed"
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.${CLI_ARCH}
install -m 755 runc.${CLI_ARCH} /usr/local/sbin/runc

mkdir -p /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-${CLI_ARCH}-v1.2.0.tgz
tar Cxzvf /opt/cni/bin cni-plugins-linux-${CLI_ARCH}-v1.2.0.tgz

mkdir /etc/containerd
containerd config default >/etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml
systemctl restart containerd

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

#Installing kubeadm, kubelet and kubectl
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt update && apt-get -qq install -y kubelet=1.26.4-00 kubeadm=1.26.4-00 && apt-mark hold kubelet kubeadm

swapoff -a
sed -i "s/\/swap.img    none    swap    sw      0       0//" /etc/fstab
mount -a

# systemctl enable kubelet
# kubeadm config images pull
