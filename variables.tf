variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

variable "k8s_hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

variable "user_name" {
}

variable "user_passwd" {
  sensitive = true # Requires terraform >= 0.14
}

variable "cluster_name" {
  default = "kubernetes"
}

variable "entrance_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx11"
}

variable "master_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx21"
}

variable "worker_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx21"
}

variable "ingress_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx21"
}

variable "network_zone" {
  description = "Predefined network zone"
  default     = "eu-central"
}

variable "location" {
  description = "Predefined location"
  default     = "nbg1"
}

variable "entrance_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "master_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "worker_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "ingress_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "master_count" {
  default = 3
}

variable "worker_count" {
  default = 2
}

variable "ingress_count" {
  default = 1
}

variable "ssh_private_key_entrance_hcloud" {
  description = "Name of the ssh key in hcloud for entrance"
  default     = "id_hetzner_entrance"
}

variable "ssh_private_key_entrance" {
  description = "Private Key to authorized the access for the entrance server"
}

variable "ssh_public_key_entrance" {
  description = "Public Key to authorized the access for the entrance server"
}

variable "ssh_private_key_nodes_hcloud" {
  description = "Name of the ssh key in hcloud for the machines"
  default     = "key_hetzner_nodes"
}

variable "ssh_private_key_nodes" {
  description = "Private Key to access the machines"
}

variable "ssh_public_key_nodes" {
  description = "Public Key to authorized the access for the machines"
}

variable "private_network_ip_range" {
  description = "IP range of private network"
  default     = "10.98.0.0/16"
}

variable "private_network_subnet_ip_range" {
  description = "IP range of private sub network"
  default     = "10.98.0.0/16"
}

variable "load_balancer_master_private_ip" {
  default = "10.98.0.2"
}

variable "master_load_balancer_type" {
  default = "lb11"
}

variable "ingress_load_balancer_type" {
  default = "lb11"
}

variable "ingress_load_balancer_name" {
  default = "load-balancer-ingreses"
}

variable "ingress_load_balancer_create_manual" {
  default = false
}

variable "pod_network_cidr" {
  default = "10.244.0.0/16"
}

variable "containerd_version" {
  default = "1.7.0"
}

variable "kubernetes_version" {
  default = "1.27.3"
}

variable "custom_ssh_port" {
  type    = number
  default = 29351
}

variable "ingress_enabled" {
  type    = bool
  default = true
}

variable "ingress_custom_values_path" {
  default = ""
}


variable "ingress_version" {
  default = "4.6.1"
}

variable "oauth2_proxy_enabled" {
  type    = bool
  default = false
}

variable "oauth2_proxy_install" {
  type    = bool
  default = false
}

variable "oauth2_proxy_custom_values_path" {
  default = ""
}

variable "oauth2_proxy_version" {
  default = "6.12.0"
}

variable "cilium_enabled" {
  type    = bool
  default = true
}

variable "cilium_version" {
  default = "1.13.4"
}


variable "cilium_custom_values_path" {
  default = ""
}

variable "hccm_enabled" {
  type    = bool
  default = true
}

variable "hccm_version" {
  default = "1.15.0"
}

variable "hccm_custom_values_path" {
  default = ""
}

variable "metric_server_enabled" {
  type    = bool
  default = false
}

variable "metric_server_version" {
  default = "3.10.0"
}

variable "metric_server_custom_values_path" {
  default = ""
}

variable "cert_manager_enabled" {
  type    = bool
  default = false
}

variable "cert_manager_version" {
  default = "1.12.1"
}

variable "cert_manager_custom_values_path" {
  default = ""
}

variable "cert_manager_acme_email" {
}

variable "relay_ui_enabled" {
  type    = bool
  default = false
}

variable "kube_prometheus_stack_enabled" {
  type    = bool
  default = false
}

variable "kube_prometheus_stack_install" {
  type    = bool
  default = false
}

variable "kube_prometheus_stack_custom_values_path" {
  default = ""
}

variable "kube_prometheus_stack_version" {
  default = "45.28.1"
}

variable "loki_enabled" {
  type    = bool
  default = false
}

variable "loki_install" {
  type    = bool
  default = false
}

variable "loki_custom_values_path" {
  default = ""
}

variable "loki_version" {
  default = "5.5.2"
}

variable "promtail_enabled" {
  type    = bool
  default = false
}

variable "promtail_install" {
  type    = bool
  default = false
}

variable "promtail_custom_values_path" {
  default = ""
}

variable "promtail_version" {
  default = "6.1.2"
}

variable "seq_version" {
  default = "2023.4.2"
}

variable "seq_enabled" {
  type    = bool
  default = false
}

variable "seq_install" {
  type    = bool
  default = false
}

variable "seq_custom_values_path" {
  default = ""
}
