# Example showing how to disable SSH access in firewalls
module "rke2_cluster" {
  source = "../../"

  # Basic cluster configuration
  cluster_name = "no-ssh-cluster"
  
  # Server configuration
  server_location = "nbg1"
  
  # Node configuration
  cluster_server_names_cp     = ["cp-1"]
  private_ips_cp             = ["10.0.1.10"]
  cluster_server_names_worker = ["worker-1", "worker-2"]
  private_ips_workers        = ["10.0.1.20", "10.0.1.21"]
  
  # Cluster sizing
  nb_cp_additional_servers = 0
  nb_worker_servers       = 2
  
  # Network configuration
  network_cidr = "10.0.0.0/16"
  subnet_cidr  = "10.0.1.0/24"
  
  # SSH configuration - DISABLED
  enable_ssh_access = false
  ssh_allowed_ips   = [] # Not used when SSH is disabled
  
  # Required variables (would be provided via terraform.tfvars)
  hcloud_token           = var.hcloud_token
  rke2_token            = var.rke2_token
  external_datastore_url = var.external_datastore_url
  aws_region            = var.aws_region
  db_username           = var.db_username
  allowed_cidr          = var.allowed_cidr
}
