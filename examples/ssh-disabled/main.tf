# Example showing how to disable SSH access in firewalls
module "rke2_cluster" {
  source = "../../"

  # Basic cluster configuration
  cluster_name = "no-ssh-cluster"

  # Server configuration
  control_plane_location = "nbg1"
  worker_location        = "nbg1"

  # Node configuration
  control_planes = {
    "1" = { private_ip = "10.0.1.10", first = true }
  }
  cluster_server_names_worker = ["1", "2"]
  private_ips_workers         = ["10.0.1.20", "10.0.1.21"]
  nb_worker_servers           = 2

  # Network configuration
  network_cidr = "10.0.0.0/16"
  subnet_cidr  = "10.0.1.0/24"

  # SSH configuration - DISABLED
  enable_ssh_access    = false
  ssh_allowed_ips      = [] # Not used when SSH is disabled
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = null # Not needed when SSH access is disabled

  # Required variables (would be provided via terraform.tfvars)
  hcloud_token = var.hcloud_token
  rke2_token   = var.rke2_token
}
