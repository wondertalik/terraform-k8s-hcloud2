
# create cloud config for entrance
data "cloudinit_config" "cloud_init_entrance" {
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
    filename     = "setup-entrance.sh"
    content_type = "text/x-shellscript"

    content = replace(file("./scripts/setup-entrance.sh"), "[kubernetes-version]", var.kubernetes_version)

  }


  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("./templates/entrance-cloud-init.tftpl", {
      "ssh_port"    = var.custom_ssh_port
      "user_passwd" = var.user_passwd
      "user_name"   = var.user_name
    })
  }
}

resource "null_resource" "firewalls" {
  depends_on = [
    hcloud_server.master,
    hcloud_server.worker,
    null_resource.init_masters,
    null_resource.init_workers,
    null_resource.init_ingreses,
    hcloud_server.entrance_server,
  ]
}


resource "hcloud_firewall" "firewall_entrance" {
  name = "firewall-entrance"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = var.custom_ssh_port
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# create entrance server
resource "hcloud_server" "entrance_server" {
  name               = "entrance-${var.location}"
  image              = var.entrance_image
  server_type        = var.entrance_type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement_cluster.id
  firewall_ids       = [hcloud_firewall.firewall_entrance.id]

  ssh_keys = [
    hcloud_ssh_key.hetzner_entrance_key.id,
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_entrance.rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  connection {
    host        = self.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p .my-settings",
      "mkdir -p .kube"
    ]
  }

  provisioner "file" {
    source      = "scripts/configure-entranse.sh"
    destination = "/tmp/configure-entranse.sh"
  }

  provisioner "file" {
    source      = "settings/kube-ps1.sh"
    destination = ".my-settings/kube-ps1.sh"
  }

  provisioner "file" {
    source      = "secrets/kubeadm_config"
    destination = ".kube/config"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 .kube/config",
      "bash /tmp/configure-entranse.sh",
    ]
  }

  labels = {
    "source" = "k8s-dev"
    "type"   = "entrance"
  }

  depends_on = [
    null_resource.init_workers,
  ]
}

resource "hcloud_server_network" "entrance_network" {
  depends_on = [
    hcloud_server.entrance_server,
    hcloud_network_subnet.private_network_subnet
  ]
  server_id = hcloud_server.entrance_server.id
  subnet_id = hcloud_network_subnet.private_network_subnet.id
}
