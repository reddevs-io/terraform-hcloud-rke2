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
  description = "Database username for RDS instance"
}

variable "allowed_cidr" {
  description = "CIDR allowed to connect to Postgres (use your IP/CIDR, not 0.0.0.0/0, for security)."
  type        = list(string)
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

# AWS VPC module variables
variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
}
