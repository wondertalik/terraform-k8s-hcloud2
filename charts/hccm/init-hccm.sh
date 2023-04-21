# #!/usr/bin/bash
set -eu

# #create secrets hcloud in k8s
kubectl -n kube-system create secret generic hcloud --from-literal=token=$K8S_HCLOUD_TOKEN --from-literal=network=$PRIVATE_NETWORK_ID

# #install hcloud-controller-manager
helm upgrade --install hccm charts/hccm/src/hcloud-cloud-controller-manager -f charts/hccm/values.yaml --namespace kube-system --set networking.clusterCIDR=$POD_NETWORK_CIDR