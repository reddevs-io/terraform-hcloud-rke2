# Hetzner Cloud Configuration
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the RKE2 cluster"
  type        = string
  default     = "example-cluster"
}

# Server Configuration
variable "control_plane_server_type" {
  description = "Server type for control plane nodes"
  type        = string
  default     = "cx22"
}

variable "worker_server_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx22"
}

variable "server_image" {
  description = "Server image to use"
  type        = string
  default     = "ubuntu-24.04"
}

variable "control_plane_location" {
  description = "Hetzner location for control plane nodes"
  type        = string
  default     = "nbg1"
}

variable "worker_location" {
  description = "Hetzner location for worker nodes"
  type        = string
  default     = "nbg1"
}

# Network Configuration
variable "network_zone" {
  description = "Network zone for the subnet"
  type        = string
  default     = "eu-central"
}

variable "network_cidr" {
  description = "CIDR block for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_allowed_ips" {
  description = "List of IPs allowed to SSH"
  type        = list(string)
  default = [
    "0.0.0.0/0" # Replace with your actual IP for security
  ]
}

variable "enable_ssh_access" {
  description = "Enable SSH access rules in firewall (port 22)"
  type        = bool
  default     = false
}

# Cluster Configuration
variable "nb_cp_additional_servers" {
  description = "Number of additional control-plane nodes in the RKE2 cluster"
  type        = number
  default     = 1
}

variable "nb_worker_servers" {
  description = "Number of worker nodes in the RKE2 cluster"
  type        = number
  default     = 2
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file to be used for server access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file corresponding to the public key."
  type        = string
  default     = null
}
