provider "hcloud" {
  token = var.hcloud_token
}

# create ssh-key for entrance
resource "hcloud_ssh_key" "hetzner_entrance_key" {
  name       = var.ssh_private_key_entrance_name
  public_key = file(var.ssh_public_key_entrance)
}

# create ssh-key for nodes
resource "hcloud_ssh_key" "hetzner_nodes_key" {
  name       = var.ssh_private_key_nodes_name
  public_key = file(var.ssh_public_key_nodes)
}

# create placement group
resource "hcloud_placement_group" "placement-cluster" {
  name = "placement-cluster-1"
  type = "spread"
  labels = {
    "source" = "k8s-dev"
  }
}

# create private network
resource "hcloud_network" "private-network" {
  name              = "k8s-private-network"
  ip_range          = var.private_network_ip_range
  delete_protection = false
  labels = {
    "type" : "k8s-private-network",
    "source" = "k8s-dev"
  }
}

resource "hcloud_network_subnet" "private-network-subnet" {
  network_id   = hcloud_network.private-network.id
  type         = "server"
  network_zone = var.network_zone
  ip_range     = var.private_network_subnet_ip_range
}

# create entrance server
resource "hcloud_server" "entrance-server" {
  name               = "entrance-${var.entrance_image}-${var.location}"
  image              = var.master_image
  server_type        = var.entrance_type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement-cluster.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_entrance_key.id,
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = templatefile("./templates/entrance-cloud-init.tftpl", {
    "ssh_port"    = var.custom_ssh_port
    "user_passwd" = var.user_passwd
    "user_name"   = var.user_name

  })
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private-network.id
  }

  labels = {
    "source" = "k8s-dev"
  }

  depends_on = [
    hcloud_network_subnet.private-network-subnet
  ]
}

# output "name" {
#   value = templatefile("./templates/entrance-cloud-init.tftpl", {
#     "ssh_port"    = var.custom_ssh_port
#     "user_passwd" = var.user_passwd
#     "user_name"   = var.user_name
#   })
#   sensitive = true
# }
