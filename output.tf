output "api_server_lb_ip" {
  description = "Load balancer IP for Kubernetes API"
  value       = hcloud_load_balancer.api_server.ipv4
}

output "control_plane_ips" {
  description = "Public IP addresses of control plane nodes"
  value = merge(
    {
      (hcloud_server.control_plane_first.name) = hcloud_server.control_plane_first.ipv4_address
    },
    {
      for i, server in hcloud_server.control_plane_additional :
      server.name => server.ipv4_address
    }
  )
}

output "worker_ips" {
  description = "Public IP addresses of worker nodes"
  value = {
    for i, server in hcloud_server.workers :
    server.name => server.ipv4_address
  }
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig from first control plane node"
  value       = "scp root@${hcloud_server.control_plane_first.ipv4_address}:/etc/rancher/rke2/rke2.yaml ${var.kubeconfig_path}"
}

output "first_control_plane_private_ip" {
  description = "Private IP of the first control plane node"
  value       = hcloud_server_network.control_plane_first_network.ip
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

output "ssh_private_key" {
  description = "Generated SSH private key"
  value       = tls_private_key.rke2_key.private_key_openssh
  sensitive   = true
}

output "ssh_public_key" {
  description = "Generated SSH public key"
  value       = tls_private_key.rke2_key.public_key_openssh
}

output "ssh_key_name" {
  description = "Name of the SSH key in Hetzner Cloud"
  value       = hcloud_ssh_key.rke2_key.name
}

output "kubeconfig" {
  description = "Admin kubeconfig content for the RKE2 cluster. Returns null if enable_ssh_access is false (default) or if kubeconfig hasn't been retrieved yet. IMPORTANT: This value is read at plan time and may be stale after cluster recreation - run 'terraform apply' twice or use kubeconfig_command for the most current kubeconfig."
  value       = local.kubeconfig_content
  sensitive   = true
}
