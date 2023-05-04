output "entrance_ips" {
  value = [hcloud_server.entrance_server.*.ipv4_address]
}

output "master_ips" {
  value = [hcloud_server.master.*.ipv4_address]
}

output "workers_ips" {
  value = [hcloud_server.worker.*.ipv4_address]
}

output "ingresses_ips" {
  value = [hcloud_server.ingress.*.ipv4_address]
}

output "network_id" {
  value = [hcloud_network.private_network.id]
}

output "subnet_network_id" {
  value = [hcloud_network_subnet.private_network_subnet.id]
}