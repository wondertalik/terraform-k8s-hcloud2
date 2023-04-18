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

# # create cloud config for entrance
# data "cloudinit_config" "cloud_init_entrance" {
#   gzip          = false
#   base64_encode = false
  
#   part {
#     filename     = "setup-basic.sh"
#     content_type = "text/x-shellscript"

#     content = templatefile("./templates/setup-basic.tftpl", {
#       "ssh_port"  = var.custom_ssh_port
#       "user_name" = var.user_name
#     })
#   }

#   part {
#     filename     = "setup-entrance.sh"
#     content_type = "text/x-shellscript"

#     content = file("./scripts/setup-entrance.sh")
#   }


#   part {
#     filename     = "cloud-config.yaml"
#     content_type = "text/cloud-config"

#     content = templatefile("./templates/entrance-cloud-init.tftpl", {
#       "ssh_port"    = var.custom_ssh_port
#       "user_passwd" = var.user_passwd
#       "user_name"   = var.user_name
#     })
#   }
# }


# # create entrance server
# resource "hcloud_server" "entrance-server" {
#   name               = "entrance-${var.entrance_image}-${var.location}"
#   image              = var.entrance_image
#   server_type        = var.entrance_type
#   location           = var.location
#   placement_group_id = hcloud_placement_group.placement-cluster.id

#   ssh_keys = [
#     hcloud_ssh_key.hetzner_entrance_key.id,
#     hcloud_ssh_key.hetzner_nodes_key.id,
#   ]
#   user_data = data.cloudinit_config.cloud_init_entrance.rendered

#   public_net {
#     ipv4_enabled = true
#     ipv6_enabled = true
#   }

#   network {
#     network_id = hcloud_network.private-network.id
#   }

#   connection {
#     host        = self.ipv4_address
#     port        = var.custom_ssh_port
#     type        = "ssh"
#     private_key = file(var.ssh_private_key_entrance)
#     user        = var.user_name
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "cloud-init status --wait"
#     ]
#   }

#   labels = {
#     "source" = "k8s-dev"
#   }

#   depends_on = [
#     hcloud_network_subnet.private-network-subnet
#   ]
# }

# create cloud config for entrance
# data "cloudinit_config" "cloud_init_node" {
#   gzip          = false
#   base64_encode = false
  
#   part {
#     filename     = "setup-node.sh"
#     content_type = "text/x-shellscript"

#     content = templatefile("./templates/setup-node.tftpl", {
#       "ssh_port"  = var.custom_ssh_port
#       "user_name" = var.user_name
#       "private_network_subnet_ip_range" = var.private_network_subnet_ip_range
#     })
#   }

#   part {
#     filename     = "setup-entrance.sh"
#     content_type = "text/x-shellscript"

#     content = file("./scripts/setup-entrance.sh")
#   }


#   part {
#     filename     = "cloud-config.yaml"
#     content_type = "text/cloud-config"

#     content = templatefile("./templates/node-cloud-init.tftpl", {
#       "ssh_port"    = var.custom_ssh_port
#       "user_passwd" = var.user_passwd
#       "user_name"   = var.user_name
#     })
#   }
# }

# resource "hcloud_server" "master-0-server" {
#   name               = "master-${var.master_image}-${var.location}-0"
#   image              = var.master_image
#   server_type        = var.master_type
#   location           = var.location
#   placement_group_id = hcloud_placement_group.placement-cluster.id

#   ssh_keys = [
#     hcloud_ssh_key.hetzner_nodes_key.id,
#   ]
#   user_data = data.cloudinit_config.cloud_init_entrance.rendered

#   public_net {
#     ipv4_enabled = false
#     ipv6_enabled = false
#   }

#   network {
#     network_id = hcloud_network.private-network.id
#   }

#   connection {
#     host        = self.ipv4_address
#     port        = var.custom_ssh_port
#     type        = "ssh"
#     private_key = file(var.ssh_private_key_entrance)
#     user        = var.user_name
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "cloud-init status --wait"
#     ]
#   }

#   # provisioner "file" {
#   #   source      = "./scripts/setup-entrance.sh"
#   #   destination = "/home/${var.user_name}/setup-entrance.sh"
#   # }

#   # provisioner "remote-exec" {
#   #   inline = ["SSH_PORT=${var.custom_ssh_port} bash  '/home/${var.user_name}/setup-entrance.sh'"]
#   # }

#   labels = {
#     "source" = "k8s-dev"
#   }

#   depends_on = [
#     hcloud_network_subnet.private-network-subnet,
#     hcloud_server.entrance-server
#   ]
# }


# output "name" {
#   value = data.cloudinit_config.cloud_init_node.rendered
#   sensitive = true
# }
