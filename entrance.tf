
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
