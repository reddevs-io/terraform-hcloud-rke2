terraform {
  required_version = ">= 1.2.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.52"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure providers
provider "hcloud" {
  token = var.hcloud_token
}

# Generate a random RKE2 token
resource "random_password" "rke2_token" {
  length  = 32
  special = true
}

# Generate control plane server names based on number of additional control plane nodes
locals {
  cp_count     = 1 + var.nb_cp_additional_servers
  worker_count = var.nb_worker_servers

  control_plane_names = [for i in range(local.cp_count) : "${var.cluster_name}-cp-${i == 0 ? "primary" : i}"]
  worker_names        = [for i in range(local.worker_count) : "${var.cluster_name}-worker-${i}"]

  # Generate private IPs for control plane nodes (starting from .10)
  control_plane_ips = [for i in range(local.cp_count) : cidrhost(var.subnet_cidr, 10 + i)]
  # Generate private IPs for worker nodes (starting after control plane)
  worker_ips = [for i in range(local.worker_count) : cidrhost(var.subnet_cidr, 10 + local.cp_count + i)]
}

# Create the RKE2 infrastructure using the module
module "rke2_infrastructure" {
  source = "../../"

  # Hetzner Cloud Configuration
  hcloud_token = var.hcloud_token
  cluster_name = var.cluster_name

  # Server Configuration
  control_plane_server_type = var.control_plane_server_type
  worker_server_type        = var.worker_server_type
  control_plane_location    = var.control_plane_location
  worker_location           = var.worker_location
  server_image              = var.server_image

  # Network Configuration
  network_cidr = var.network_cidr
  subnet_cidr  = var.subnet_cidr
  network_zone = var.network_zone

  # SSH Access
  ssh_allowed_ips   = var.ssh_allowed_ips
  enable_ssh_access = var.enable_ssh_access

  # Cluster Configuration - Server Names
  cluster_server_names_cp     = local.control_plane_names
  cluster_server_names_worker = local.worker_names

  # Cluster Configuration - Private IPs
  private_ips_cp      = local.control_plane_ips
  private_ips_workers = local.worker_ips

  # Cluster Configuration - Node Counts
  nb_cp_additional_servers = var.nb_cp_additional_servers
  nb_worker_servers        = var.nb_worker_servers

  # RKE2 Configuration
  rke2_token = random_password.rke2_token.result

  # Datastore Configuration (optional - uses embedded etcd if not provided)
  # datastore_endpoint = var.datastore_endpoint
}
