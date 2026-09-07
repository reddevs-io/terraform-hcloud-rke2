terraform {
  required_version = ">= 1.8.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.68"
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

# Derive node names and private IPs from the requested counts
locals {
  worker_count = var.nb_worker_servers

  # Control planes keyed by short name; the first one initialises the cluster.
  # Private IPs start at .10, workers follow after the control planes.
  control_planes = {
    for i in range(1 + var.nb_cp_additional_servers) :
    (i == 0 ? "primary" : tostring(i)) => {
      private_ip = cidrhost(var.subnet_cidr, 10 + i)
      first      = i == 0
    }
  }

  worker_names = [for i in range(local.worker_count) : "${i}"]
  worker_ips   = [for i in range(local.worker_count) : cidrhost(var.subnet_cidr, 10 + length(local.control_planes) + i)]
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
  ssh_allowed_ips      = var.ssh_allowed_ips
  enable_ssh_access    = var.enable_ssh_access
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path

  # Control planes (per-node type/location override the defaults above)
  control_planes = local.control_planes

  # Workers
  cluster_server_names_worker = local.worker_names
  private_ips_workers         = local.worker_ips
  nb_worker_servers           = var.nb_worker_servers

  # RKE2 Configuration
  rke2_token = random_password.rke2_token.result

  # Datastore Configuration (optional - uses embedded etcd if not provided)
  # datastore_endpoint = var.datastore_endpoint
}
