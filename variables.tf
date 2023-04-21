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

variable "master_count" {
}

variable "worker_count" {
}

variable "ssh_private_key_entrance_name" {
  description = "Name of the ssh key in hcloud for entrance"
  default     = "key_hetzner_entrance"
}

variable "ssh_private_key_entrance" {
  description = "Private Key to access the machines"
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_public_key_entrance" {
  description = "Public Key to authorized the access for the machines"
}

variable "ssh_private_key_nodes_name" {
  description = "Name of the ssh key in hcloud for nodes"
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

variable "load_balancer_type" {
  default = "lb11"
}

variable "pod_network_cidr" {
  default = "172.16.0.0/16"
}

variable "containerd_version" {
  default = "1.7.0"
}

variable "kubernetes_version" {
  default = "1.26.4"
}

variable "custom_ssh_port" {
  type    = number
  default = 22
}

variable "cilium_enabled" {
  type    = bool
  default = true
}

variable "hccm_enabled" {
  type    = bool
  default = true
}

variable "metric_server_enabled" {
  type    = bool
  default = true
}
