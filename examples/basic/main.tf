terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure providers
provider "aws" {
  region = var.aws_region
}

provider "hcloud" {
  token = var.hcloud_token
}

# Generate a random RKE2 token
resource "random_password" "rke2_token" {
  length  = 32
  special = true
}

# Create the RKE2 infrastructure using the module
module "rke2_infrastructure" {
  source = "../../"

  # Hetzner Cloud Configuration
  hcloud_token = var.hcloud_token
  cluster_name = var.cluster_name

  # Server Configuration
  server_type     = var.server_type
  server_location = var.server_location
  server_image    = var.server_image

  # Network Configuration
  network_cidr = var.network_cidr
  subnet_cidr  = var.subnet_cidr
  network_zone = var.network_zone

  # SSH Access
  ssh_allowed_ips = var.ssh_allowed_ips

  # Cluster Configuration
  nb_cp_additional_servers = var.nb_cp_additional_servers
  nb_worker_servers        = var.nb_worker_servers

  # RKE2 Configuration
  rke2_token = random_password.rke2_token.result

  # AWS RDS Configuration
  aws_region             = var.aws_region
  external_datastore_url = var.external_datastore_url
  db_username            = var.db_username
  allowed_cidr           = var.allowed_cidr
  allocated_storage_gb   = var.allocated_storage_gb
  engine_version         = var.engine_version
}
