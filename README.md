# Terraform Kubernetes on Hetzner Cloud

This repository will help to setup an opionated Kubernetes Cluster with [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) on [Hetzner Cloud](https://www.hetzner.com/cloud?country=us).

## Usage

# Install and configure hcloud

## Create hetzner project

1. Open [console](https://console.hetzner.cloud) and create [project](https://docs.hetzner.com/cloud/general/faq). Next will be used  `k8s-dev-stand`
2. Create [api token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token) with permissions *Read & Write* from projet `k8s-dev-stand`

### Generate ssh-keys for servers

Generate a new SSH keys in your terminal called `id_hetzner_entrance` and `id_hetzner_nodes`. The argument provided with the -f flag creates the key in the current directory and creates four files called id_hetzner_entrance, id_hetzner_entrance.pub and id_hetzner_nodes, id_hetzner_nodes.pub. Change the placeholder email address to your email address.


- Generate ssh-key for proxy server

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_hetzner_proxy
```

- Generate ssh-key for entrance server

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_hetzner_entrance
```

- Generate ssh-key for internal connections

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_hetzner_nodes
```



# How to use

```sh
$ git clone https://github.com/wondertalik/terraform-k8s-hcloud
$ terraform init
$ terraform plan -out="k8s-dev-stand.plan"
$ terraform apply "k8s-dev-stand.plan"
```

## Variables

| Name                    | Default                 | Description                                                                                                                                              | Required |
| :---------------------- | :---------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| `hcloud_token`          | ``                      | API Token that will be generated through your hetzner cloud project https://console.hetzner.cloud/projects                                               |   Yes    |
| `k8s_hcloud_token`      | ``                      | API Token that will be generated through your hetzner cloud project https://console.hetzner.cloud/projects, used by k8s                                  |   Yes    |
| `master_count`          | `1`                     | Amount of masters that will be created                                                                                                                   |    No    |
| `master_image`          | `ubuntu-20.04`          | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-20.04, ubuntu-18.04)                                             |    No    |
| `master_type`           | `cx11`                  | Machine type for more types have a look at https://www.hetzner.de/cloud                                                                                  |    No    |
| `node_count`            | `1`                     | Amount of nodes that will be created                                                                                                                     |    No    |
| `node_image`            | `ubuntu-20.04`          | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-20.04, ubuntu-18.04)                                             |    No    |
| `node_type`             | `cx11`                  | Machine type for more types have a look at https://www.hetzner.de/cloud                                                                                  |    No    |
| `ssh_private_key`       | `~/.ssh/id_ed25519`     | Private Key to access the machines                                                                                                                       |    No    |
| `ssh_public_key`        | `~/.ssh/id_ed25519.pub` | Public Key to authorized the access for the machines                                                                                                     |    No    |
| `kubernetes_version`    | `1.26.4`                | Kubernetes version that will be installed                                                                                                                |    No    |
| `cilium_enabled`        | `true`                  | Installs Cilium Network Provider after the master comes up                                                                                               |    No    |
| `hccm_enabled`          | `true`                  | Installs Hetzner Cloud Provider after the master comes up                                                                                                |    No    |
| `metric_server_enabled` | `true`                  | Installs Metrics Server after the master comes up                                                                                                        |    No    |
| `user_name`             | ``                      | User that wil be created in all nodes                                                                                                                    |   Yes    |
| `user_passwd`           | ``                      | Password hash `` for new user created by [`mkpasswd --method=SHA-512 --rounds=4096`](https://cloudinit.readthedocs.io/en/latest/reference/examples.html) |   Yes    |

All variables cloud be passed through `environment variables` or a `tfvars` file.

An example for a `tfvars` file would be the following `terraform.tfvars`

```toml
# terraform.tfvars
hcloud_token                    = "<yourgeneratedtoken>"
k8s_hcloud_token                = "<yourgeneratedtoken>"
entrance_type                   = "cx11"
master_type                     = "cx21"
master_count                    = 3
worker_type                     = "cx21"
worker_count                    = 2
kubernetes_version              = "1.26.4"
containerd_version              = "1.7.0"
private_network_ip_range        = "10.98.0.0/16"
private_network_subnet_ip_range = "10.98.0.0/16"
load_balancer_master_private_ip = "10.98.0.2"
ssh_private_key_entrance        = "~/.ssh/id_hetzner_entrance"
ssh_public_key_entrance         = "~/.ssh/id_hetzner_entrance.pub"
ssh_private_key_nodes           = "~/.ssh/id_hetzner_nodes"
ssh_public_key_nodes            = "~/.ssh/id_hetzner_nodes.pub"
custom_ssh_port                 = 22320
user_name                       = "admin"
user_passwd                     = "<yourgeneratedtoken>"

```

Or passing directly via Arguments

```console
$ terraform apply \
  -var hcloud_token="<yourgeneratedtoken>" \
-var hcloud_token="<yourgeneratedtoken>" \
- var k8s_hcloud_token="<yourgeneratedtoken>" \
- var entrance_type="cx11" \
- var master_typ="cx21" \
- var master_count= 3 \
- var worker_type="cx21" \
- var worker_count= 2 \
- var kubernetes_version="1.26.4" \
- var containerd_version="1.7.0" \
- var private_network_ip_range="10.98.0.0/16" \
- var private_network_subnet_ip_range ="10.98.0.0/16" \
- var load_balancer_master_private_ip ="10.98.0.2" \
- var ssh_private_key_entrance="~/.ssh/id_hetzner_entrance" \
- var ssh_public_key_entrance="~/.ssh/id_hetzner_entrance.pub" \
- var ssh_private_key_nodes="~/.ssh/id_hetzner_nodes" \
- var ssh_public_key_nodes="~/.ssh/id_hetzner_nodes.pub" \
- var custom_ssh_port= 22320 \
- var user_name="admin" \
- var user_passwd="<yourgeneratedtoken>"
```

**Tested with**

- Terraform [v1.4.4](https://github.com/hashicorp/terraform/tree/v1.4.4)
- provider.hcloud [v1.38.2](https://github.com/terraform-providers/terraform-provider-hcloud)
- hashicorp/null [v3.2.1](https://github.com/terraform-providers/terraform-provider-hcloud)

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/wondertalik/terraform-k8s-hcloud/issues) to report any bugs or file feature requests.

