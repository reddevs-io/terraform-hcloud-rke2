# Required variables for the SSH-disabled example
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "rke2_token" {
  description = "RKE2 cluster token"
  type        = string
  sensitive   = true
}

variable "external_datastore_url" {
  type        = string
  description = "External datastore for k8s control-plane"
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region for RDS instance"
  default     = "eu-central-1"
}

variable "db_username" {
  type        = string
  description = "Database username for RDS instance"
  default     = "postgres"
}

variable "allowed_cidr" {
  description = "CIDR allowed to connect to Postgres"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
