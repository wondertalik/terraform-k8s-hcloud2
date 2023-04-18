resource "hcloud_ssh_key" "hetzner_proxy_key" {
  name       = var.ssh_private_key_proxy_name
  public_key = file(var.ssh_public_key_proxy)
}

# create cloud config for proxy
data "cloudinit_config" "cloud_init_proxy" {
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

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("./templates/proxy-cloud-init.tftpl", {
      "ssh_port"              = var.custom_ssh_port
      "user_passwd"           = var.user_passwd
      "user_name"             = var.user_name
      "private_network_range" = var.private_network_subnet_ip_range
    })
  }
}

# create proxy server
resource "hcloud_server" "proxy-server" {
  name               = "proxy-${var.proxy_image}-${var.location}"
  image              = var.proxy_image
  server_type        = var.proxy_type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement-cluster.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_proxy_key.id,
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_proxy.rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private-network.id
    ip         = var.proxy_ip
  }

  connection {
    host        = self.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_proxy)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  labels = {
    "source" = "k8s-dev"
    "type"   = "proxy"
  }

  depends_on = [
    hcloud_network_subnet.private-network-subnet
  ]
}
