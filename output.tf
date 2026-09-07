output "api_server_lb_ip" {
  description = "Load balancer public IP for Kubernetes API"
  value       = hcloud_load_balancer.api_server.ipv4
}

output "api_server_lb_private_ip" {
  description = "Load balancer private IP (RKE2 nodes join through https://<ip>:9345)"
  value       = hcloud_load_balancer_network.api_server.ip
}

output "control_plane_ips" {
  description = "Public IP addresses of control plane nodes keyed by server name"
  value = {
    for k, server in hcloud_server.control_plane :
    server.name => server.ipv4_address
  }
}

output "control_plane_private_ips" {
  description = "Private IP addresses of control plane nodes keyed by server name"
  value = {
    for k, v in local.control_planes :
    v.name => v.private_ip
  }
}

output "control_plane_ids" {
  description = "Hetzner server IDs of control plane nodes keyed by server name"
  value = {
    for k, server in hcloud_server.control_plane :
    server.name => server.id
  }
}

output "worker_ips" {
  description = "Public IP addresses of worker nodes"
  value = {
    for i, server in hcloud_server.workers :
    server.name => server.ipv4_address
  }
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig from the first control plane node"
  value       = var.ssh_private_key_path != null ? "scp -i ${var.ssh_private_key_path} root@${hcloud_server.control_plane[local.first_control_plane_key].ipv4_address}:/etc/rancher/rke2/rke2.yaml ./kubeconfig.yaml" : "scp root@${hcloud_server.control_plane[local.first_control_plane_key].ipv4_address}:/etc/rancher/rke2/rke2.yaml ./kubeconfig.yaml"
}

output "first_control_plane_private_ip" {
  description = "Private IP of the first control plane node"
  value       = local.control_planes[local.first_control_plane_key].private_ip
}

output "private_network_cidr" {
  description = "Private network CIDR"
  value       = hcloud_network.rke2_network.ip_range
}

output "private_network_id" {
  description = "Hetzner Cloud private network ID"
  value       = hcloud_network.rke2_network.id
}

output "subnet_id" {
  description = "Hetzner Cloud subnet ID"
  value       = hcloud_network_subnet.rke2_subnet.id
}

output "ssh_key_name" {
  description = "Name of the SSH key in Hetzner Cloud"
  value       = hcloud_ssh_key.rke2_key.name
}
