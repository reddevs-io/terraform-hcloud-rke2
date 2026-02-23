variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the RKE2 cluster"
  type        = string
  default     = "rke2-cluster"
}

variable "cluster_server_names_cp" {
  description = "List of control plane node server names"
  type        = list(string)
}

variable "private_ips_cp" {
  description = "List of control plane nodes private IPs"
  type        = list(string)
}

variable "cluster_server_names_worker" {
  description = "List of worker node server names"
  type        = list(string)
}

variable "private_ips_workers" {
  description = "List of worker nodes private IPs"
  type        = list(string)
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx32"
}

variable "server_image" {
  description = "Server image to use"
  type        = string
  default     = "ubuntu-24.04"
}

variable "server_location" {
  description = "Server location"
  type        = string
}

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
}

variable "enable_ssh_access" {
  description = "Enable SSH access rules in firewall (port 22)"
  type        = bool
  default     = false
}

variable "rke2_token" {
  description = "RKE2 cluster token"
  type        = string
  sensitive   = true
}

variable "nb_cp_additional_servers" {
  description = "Number of additional control-plane nodes in the RKE2 cluster"
  type        = number
}

variable "nb_worker_servers" {
  description = "Number of worker nodes in the RKE2 cluster"
  type        = number
}

variable "datastore_endpoint" {
  description = "External datastore endpoint URL for RKE2 (e.g. postgres://user:password@host:5432/dbname). If not set, RKE2 will use the embedded etcd."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_key_algorithm" {
  description = "Algorithm for SSH key generation"
  type        = string
  default     = "ED25519"
  validation {
    condition     = contains(["RSA", "ED25519", "ECDSA"], var.ssh_key_algorithm)
    error_message = "SSH key algorithm must be one of: RSA, ED25519, ECDSA."
  }
}
