output "api_server_lb_ip" {
  description = "Load balancer IP for Kubernetes API"
  value       = module.rke2_infrastructure.api_server_lb_ip
}

output "control_plane_ips" {
  description = "Public IP addresses of control plane nodes"
  value       = module.rke2_infrastructure.control_plane_ips
}

output "worker_ips" {
  description = "Public IP addresses of worker nodes"
  value       = module.rke2_infrastructure.worker_ips
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig from first control plane node"
  value       = module.rke2_infrastructure.kubeconfig_command
}

output "first_control_plane_private_ip" {
  description = "Private IP of the first control plane node"
  value       = module.rke2_infrastructure.first_control_plane_private_ip
}

output "private_network_cidr" {
  description = "Private network CIDR"
  value       = module.rke2_infrastructure.private_network_cidr
}

output "private_network_id" {
  description = "Hetzner Cloud private network ID"
  value       = module.rke2_infrastructure.private_network_id
}

output "subnet_id" {
  description = "Hetzner Cloud subnet ID"
  value       = module.rke2_infrastructure.subnet_id
}

output "ssh_key_name" {
  description = "Name of the SSH key in Hetzner Cloud"
  value       = module.rke2_infrastructure.ssh_key_name
}

output "rke2_token" {
  description = "Generated RKE2 cluster token"
  value       = random_password.rke2_token.result
  sensitive   = true
}
