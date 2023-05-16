resource "null_resource" "hccm" {
  depends_on = [
    null_resource.init_masters
  ]

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
}

resource "null_resource" "cilium" {
  depends_on = [
    null_resource.hccm,
  ]

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
      "MASTER_COUNT=${var.master_count} RELAY_UI_ENABLED=${var.relay_ui_enabled} POD_NETWORK_CIDR=${var.pod_network_cidr} CONTROL_PLANE_ENDPOINT=${var.load_balancer_master_private_ip} bash charts/cilium/install.sh",
      "echo \"source <(cilium completion bash)\" >> .bashrc"
    ]
  }

}

resource "null_resource" "hcloud_csi" {
  depends_on = [null_resource.hccm]
  count      = var.hccm_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p manifests"]
  }

  provisioner "file" {
    source      = "manifests/hcloud-csi.yml"
    destination = "manifests/hcloud-csi.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f manifests/hcloud-csi.yml"
    ]
  }
}

resource "null_resource" "metric_server" {
  depends_on = [
    null_resource.init_masters
  ]
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
}

resource "null_resource" "ingress_nginx" {
  depends_on = [
    null_resource.init_ingreses,
  ]
  count = var.ingress_enabled && var.ingress_count > 0 ? 1 : 0

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

  provisioner "file" {
    source      = "charts/oauth2-proxy"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "LOCATION=${var.location} INGRESS_LOAD_BALANCER_NAME=${var.ingress_load_balancer_name} INGRESS_LOAD_BALANCER_TYPE=${var.ingress_load_balancer_type}  NODE_NAME=ingress-${var.location} NODE_COUNT=${var.ingress_count} bash charts/ingress-nginx/install.sh"
    ]
  }
}

resource "null_resource" "cert_manager" {
  depends_on = [
    null_resource.init_masters,
  ]
  triggers = {
    cert_manager_version = var.cert_manager_version
  }
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

  provisioner "remote-exec" {
    inline = ["rm -rf charts/cert-manager"]
  }

  provisioner "file" {
    source      = "charts/cert-manager"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "CERT_MANAGER_VERSION=${var.cert_manager_version} ACME_EMAIL=${var.cert_manager_acme_email} bash charts/cert-manager/install.sh"
    ]
  }
}

resource "null_resource" "kube-prometheus-stack" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    kube_rometheus_stack_version = var.kube_prometheus_stack_version
  }
  count = var.kube_prometheus_stack_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/kube-prometheus-stack"
    ]
  }

  provisioner "file" {
    source      = "charts/kube-prometheus-stack"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "KUBE_PROMETHEUS_STACK_VERSION=${var.kube_prometheus_stack_version} KUBE_PROMETHEUS_STACK_INSTALL=${var.kube_prometheus_stack_install} bash charts/kube-prometheus-stack/install.sh"
    ]
  }
}

resource "null_resource" "loki" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    loki_version = var.loki_version
  }
  count = var.loki_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/loki"
    ]
  }

  provisioner "file" {
    source      = "charts/loki"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "LOKI_VERSION=${var.loki_version} LOKI_INSTALL=${var.loki_install} bash charts/loki/install.sh"
    ]
  }
}

resource "null_resource" "promtail" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    promtail_version = var.promtail_version
  }
  count = var.promtail_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/promtail"
    ]
  }

  provisioner "file" {
    source      = "charts/promtail"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "PROMTAIL_VERSION=${var.promtail_version} PROMTAIL_INSTALL=${var.promtail_install} bash charts/promtail/install.sh"
    ]
  }
}

resource "null_resource" "post_restart_masters" {
  depends_on = [
    null_resource.cilium,
    null_resource.hccm
  ]
  count = var.master_count

  connection {
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.master_network[count.index].ip
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
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.worker_network[count.index].ip
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
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.ingress_network[count.index].ip
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo systemctl daemon-reload && sudo systemctl restart kubelet"]
  }
}


