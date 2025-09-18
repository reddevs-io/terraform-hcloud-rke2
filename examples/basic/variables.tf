# AWS Configuration
variable "aws_region" {
  description = "AWS region for RDS instance"
  type        = string
  default     = "eu-central-1"
}

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
variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx22"
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

# AWS RDS Configuration
variable "external_datastore_url" {
  type        = string
  description = "External datastore for k8s control-plane"
  sensitive   = true
}

variable "db_username" {
  type        = string
  description = "Database username for RDS instance"
  default     = "postgres"
}

variable "allowed_cidr" {
  description = "CIDR allowed to connect to Postgres (use your IP/CIDR, not 0.0.0.0/0, for security)."
  type        = list(string)
  default = [
    "10.0.0.0/16" # Allow access from the Hetzner private network
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
