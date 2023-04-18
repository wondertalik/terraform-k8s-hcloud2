
# create cloud config for nodes
data "cloudinit_config" "cloud_init_nodes" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "setup-basic.sh"
    content_type = "text/x-shellscript"

    content = templatefile("./templates/setup-basic.tftpl", {
      "ssh_port"  = var.custom_ssh_port
      "user_name" = var.user_name
    })
  }

  # part {
  #   filename     = "setup-node.sh"
  #   content_type = "text/x-shellscript"

  #   content = file("./scripts/setup-node.sh")
  # }

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("./templates/node-cloud-init.tftpl", {
      "user_passwd" = var.user_passwd
      "user_name"   = var.user_name
      "proxy_ip"    = var.proxy_ip
      "proxy_port"  = var.proxy_port
    })
  }
}

# create nodes server
resource "hcloud_server" "master-server" {
  name               = "master-${var.master_image}-${var.location}"
  image              = var.master_image
  server_type        = var.master_type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement-cluster.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_nodes.rendered

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.private-network.id
    ip         = var.master_ip
  }

  connection {
    bastion_host        = hcloud_server.proxy-server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_proxy)
    bastion_user        = var.user_name
    host                = var.master_ip
    port                = var.custom_ssh_port
    type                = "ssh"
    private_key         = file(var.ssh_private_key_nodes)
    user                = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  labels = {
    "source" = "k8s-dev"
  }

  depends_on = [
    hcloud_network_subnet.private-network-subnet,
    hcloud_server.proxy-server
  ]
}
