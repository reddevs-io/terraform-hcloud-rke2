variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the RKE2 cluster"
  type        = string
  default     = "uhuru"
}

variable "cluster_server_names_cp" {
  description = "List of control plane node server names"
  type        = list(string)
  default     = ["nkrumah", "sankara", "nyerere"]
}

variable "private_ips_cp" {
  description = "List of control plane nodes private IPs"
  type        = list(string)
  default     = ["10.0.1.2", "10.0.1.3", "10.0.1.4"]
}

variable "cluster_server_names_worker" {
  description = "List of worker node server names"
  type        = list(string)
  default     = ["kenyatta", "machel"]
}

variable "private_ips_workers" {
  description = "List of worker nodes private IPs"
  type        = list(string)
  default     = ["10.0.1.5", "10.0.1.6"]
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
  default     = "nbg1"
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
  default = [
    "1.1.1.1/32", # Replace with your IPv4 address
  ]
}

variable "rke2_token" {
  description = "RKE2 cluster token"
  type        = string
  sensitive   = true
}

variable "nb_cp_additional_servers" {
  description = "Number of additional control-plane nodes in the RKE2 cluster"
  type        = number
  default     = 2
}

variable "nb_worker_servers" {
  description = "Number of worker nodes in the RKE2 cluster"
  type        = number
  default     = 2
}

variable "external_datastore_url" {
  type        = string
  description = "External datastore for k8s control-plane"
  sensitive   = true
}

# AWS RDS RKE2 datastore variables

variable "aws_region" {
  type        = string
  description = "AWS region for RDS instance"
}

variable "db_username" {
  type        = string
  default     = "arson7090"
  description = "Database username for RDS instance"
}

variable "allowed_cidr" {
  description = "CIDR allowed to connect to Postgres (use your IP/CIDR, not 0.0.0.0/0, for security)."
  type        = list(string)
  default = [
    "85.201.175.100/32", #Francis' IP address
  ]
}

variable "allocated_storage_gb" {
  type        = number
  default     = 20
  description = "Keep at or below 20GB for Free Tier."
}

variable "engine_version" {
  type        = string
  default     = "17.6"
  description = "PostgreSQL engine version"
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
