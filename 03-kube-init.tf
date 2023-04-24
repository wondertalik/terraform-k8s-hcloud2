resource "null_resource" "init_main_master" {
  connection {
    host        = hcloud_server.master[0].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p scripts"
    ]
  }

  provisioner "file" {
    source      = "scripts/kube-main-master.sh"
    destination = "scripts/kube-main-master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "SSH_USERNAME=${var.user_name} POD_NETWORK_CIDR=${var.pod_network_cidr} CONTROL_PLANE_ENDPOINT=${var.load_balancer_master_private_ip} APISERVER_ADVERTISE_ADDRESS=${hcloud_server.master[0].ipv4_address} APISERVER_CERT_EXTRA_SANS=${hcloud_server.master[0].ipv4_address} bash ./scripts/kube-main-master.sh"
    ]
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/secrets && touch ${path.module}/secrets/kubeadm_control_plane_join && touch ${path.module}/secrets/kubeadm_join && touch ${path.module}/secrets/kubeadm_config"
  }

  provisioner "local-exec" {
    command = "bash scripts/copy-kubeadm-secrets.sh"

    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key_nodes
      SSH_USERNAME    = var.user_name
      SSH_PORT        = var.custom_ssh_port
      SSH_HOST        = hcloud_server.master[0].ipv4_address
      TARGET          = "${path.module}/secrets/"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/kubeadm",
      "rm -rf scripts"
    ]
  }

  depends_on = [
    hcloud_load_balancer_network.master_load_balancer_network
  ]
}

resource "null_resource" "init_masters" {
  depends_on = [null_resource.init_main_master]
  count      = var.master_count
  connection {
    host        = hcloud_server.master[count.index].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p scripts"
    ]
  }

  provisioner "file" {
    source      = "scripts/kube-master.sh"
    destination = "scripts/kube-master.sh"
  }

  provisioner "file" {
    source      = "${path.module}/secrets/kubeadm_control_plane_join"
    destination = "/tmp/kubeadm_control_plane_join"
  }

  provisioner "remote-exec" {
    inline = ["MASTER_INDEX=${count.index} bash scripts/kube-master.sh"]
  }

  provisioner "remote-exec" {
    inline = [
      "rm /tmp/kubeadm_control_plane_join",
      "rm -rf scripts"
    ]
  }

}

resource "null_resource" "init_workers" {
  depends_on = [null_resource.init_masters]
  count      = var.worker_count
  connection {
    host        = hcloud_server.worker[count.index].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p scripts"
    ]
  }

  provisioner "file" {
    source      = "scripts/kube-node.sh"
    destination = "scripts/kube-node.sh"
  }

  provisioner "file" {
    source      = "${path.module}/secrets/kubeadm_join"
    destination = "/tmp/kubeadm_join"
  }

  provisioner "remote-exec" {
    inline = ["bash scripts/kube-node.sh"]
  }

  provisioner "remote-exec" {
    inline = [
      "rm /tmp/kubeadm_join",
      "rm -rf scripts"
    ]
  }

}

resource "null_resource" "init_ingreses" {
  depends_on = [null_resource.init_masters]
  count      = var.ingress_count
  connection {
    host        = hcloud_server.ingress[count.index].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p scripts"
    ]
  }

  provisioner "file" {
    source      = "scripts/kube-node.sh"
    destination = "scripts/kube-node.sh"
  }

  provisioner "file" {
    source      = "${path.module}/secrets/kubeadm_join"
    destination = "/tmp/kubeadm_join"
  }

  provisioner "remote-exec" {
    inline = ["bash scripts/kube-node.sh"]
  }

  provisioner "remote-exec" {
    inline = [
      "rm /tmp/kubeadm_join",
      "rm -rf scripts"
    ]
  }

}
