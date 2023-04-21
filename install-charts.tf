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
      "bash charts/cilium/init-cilium.sh"
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
      "K8S_HCLOUD_TOKEN=${var.k8s_hcloud_token} PRIVATE_NETWORK_ID=${hcloud_network.private_network.id} POD_NETWORK_CIDR=${var.pod_network_cidr} bash charts/hccm/init-hccm.sh"
    ]
  }

  depends_on = [
    hcloud_server_network.entrance_network
  ]
}
