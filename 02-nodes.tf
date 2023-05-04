
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

  part {
    filename     = "setup-node.sh"
    content_type = "text/x-shellscript"

    content = replace(file("./scripts/setup-node.sh"), "[kubernetes-version]", var.kubernetes_version)
  }

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("./templates/node-cloud-init.tftpl", {
      "user_passwd" = var.user_passwd
      "user_name"   = var.user_name
    })
  }
}

# create masters server
resource "hcloud_server" "master" {
  count              = var.master_count
  name               = "master-${var.location}-${count.index + 1}"
  image              = var.master_image
  server_type        = var.master_type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement_cluster.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_nodes.rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  connection {
    host        = self.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  labels = {
    "source" = "k8s-dev"
    "type"   = "master-node"
  }
}

resource "hcloud_server_network" "master_network" {
  depends_on = [
    hcloud_server.master,
    hcloud_network_subnet.private_network_subnet,
    hcloud_load_balancer_network.master_load_balancer_network
  ]
  count     = var.master_count
  server_id = hcloud_server.master[count.index].id
  subnet_id = hcloud_network_subnet.private_network_subnet.id
}



resource "hcloud_server" "worker" {
  count              = var.worker_count
  name               = "worker-${var.location}-${count.index + 1}"
  image              = var.worker_image
  server_type        = var.worker_type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement_cluster.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_nodes.rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  connection {
    host        = self.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  labels = {
    "source" = "k8s-dev"
    "type"   = "worker-node"
  }
}

resource "hcloud_server_network" "worker_network" {
  depends_on = [
    hcloud_load_balancer_network.master_load_balancer_network
  ]
  count     = var.worker_count
  server_id = hcloud_server.worker[count.index].id
  subnet_id = hcloud_network_subnet.private_network_subnet.id
}


resource "hcloud_server" "ingress" {
  count              = var.ingress_count
  name               = "ingress-${var.location}-${count.index + 1}"
  image              = var.ingress_image
  server_type        = var.ingress_type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement_cluster.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_nodes.rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  connection {
    host        = self.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  labels = {
    "source" = "k8s-dev"
    "type"   = "ingress-node"
  }
}

resource "hcloud_server_network" "ingress_network" {
  depends_on = [
    hcloud_load_balancer_network.master_load_balancer_network
  ]
  count     = var.ingress_count
  server_id = hcloud_server.ingress[count.index].id
  subnet_id = hcloud_network_subnet.private_network_subnet.id
}



resource "hcloud_firewall" "firewall_masters" {
  count = var.master_count > 0 ? 1 : 0
  name  = "firewall-masters"

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
    port      = 6443
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2379-2380"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 10250
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 10259
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 10257
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 4240
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = 8472
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "8080-8081"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "4244-4245"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = 53
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
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
  apply_to {
    label_selector = "type=master-node"
  }
}

resource "hcloud_firewall" "firewall_workers" {
  count = var.worker_count > 0 || var.ingress_count > 0 ? 1 : 0
  name  = "firewall-workers"

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
    port      = 10250
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 4240
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = 8472
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "8080-8081"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "4244-4245"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "udp"
    port      = 53
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 80
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = 443
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
  apply_to {
    label_selector = "type in (worker-node,ingress-node)"
  }
}
