resource "null_resource" "cilium" {
  count = var.cilium_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p charts"]
  }

  provisioner "file" {
    source      = "charts/cilium"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "MASTER_COUNT=${var.master_count} POD_NETWORK_CIDR=${var.pod_network_cidr} CONTROL_PLANE_ENDPOINT=${var.load_balancer_master_private_ip} bash charts/cilium/install.sh"
    ]
  }

  depends_on = [
    hcloud_server_network.entrance_network
  ]
}

resource "null_resource" "hccm" {
  count = var.hccm_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p charts"]
  }

  provisioner "file" {
    source      = "charts/hccm"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "K8S_HCLOUD_TOKEN=${var.k8s_hcloud_token} PRIVATE_NETWORK_ID=${hcloud_network.private_network.id} POD_NETWORK_CIDR=${var.pod_network_cidr} bash charts/hccm/install.sh"
    ]
  }

  depends_on = [
    hcloud_server_network.entrance_network,
    null_resource.cilium
  ]
}

resource "null_resource" "post_restart_masters" {
  depends_on = [
    null_resource.cilium,
    null_resource.hccm
  ]
  count = var.master_count
  connection {
    host        = hcloud_server.master[count.index].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo systemctl daemon-reload && sudo systemctl restart kubelet"]
  }
}

resource "null_resource" "post_restart_workers" {
  depends_on = [
    null_resource.cilium,
    null_resource.hccm
  ]
  count = var.worker_count
  connection {
    host        = hcloud_server.worker[count.index].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo systemctl daemon-reload && sudo systemctl restart kubelet"]
  }
}

resource "null_resource" "post_restart_ingresses" {
  depends_on = [
    null_resource.cilium,
    null_resource.hccm
  ]
  count = var.ingress_count
  connection {
    host        = hcloud_server.ingress[count.index].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo systemctl daemon-reload && sudo systemctl restart kubelet"]
  }
}

resource "null_resource" "metric_server" {
  count = var.metric_server_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p charts"]
  }

  provisioner "file" {
    source      = "charts/metrics-server"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "bash charts/metrics-server/install.sh"
    ]
  }

  depends_on = [
    hcloud_server_network.entrance_network
  ]
}

resource "null_resource" "ingress_nginx" {
  count = var.ingress_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p charts"]
  }

  provisioner "file" {
    source      = "charts/ingress-nginx"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "NODE_NAME=ingress-${var.location} NODE_COUNT=${var.ingress_count} bash charts/ingress-nginx/install.sh"
    ]
  }

  depends_on = [
    hcloud_server_network.entrance_network
  ]
}

resource "null_resource" "cert_manager" {
  count = var.cert_manager_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p charts"]
  }

  provisioner "file" {
    source      = "charts/cert-manager"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "ACME_EMAIL=${var.cert_manager_acme_email} bash charts/cert-manager/install.sh"
    ]
  }

  depends_on = [
    hcloud_server_network.entrance_network
  ]
}


