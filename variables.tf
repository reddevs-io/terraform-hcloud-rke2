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

variable "control_plane_server_type" {
  description = "Server type for control plane nodes"
  type        = string
  default     = "cx22"
}

variable "worker_server_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx22"
}

variable "server_image" {
  description = "Server image to use"
  type        = string
  default     = "ubuntu-24.04"
}

variable "control_plane_location" {
  description = "Hetzner location for control plane nodes"
  type        = string
  default     = "nbg1"
}

variable "worker_location" {
  description = "Hetzner location for worker nodes"
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

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file to be used for server access. Must be an absolute path or relative path (tilde ~ is not supported)."
  type        = string

  validation {
    condition     = !startswith(var.ssh_public_key_path, "~")
    error_message = "The ssh_public_key_path cannot start with ~. Use absolute paths (e.g., /home/user/.ssh/id_ed25519.pub) or relative paths (e.g., ./id_ed25519.pub)."
  }
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file corresponding to the public key. Required when enable_ssh_access is true for kubeconfig retrieval. Must be an absolute path or relative path (tilde ~ is not supported)."
  type        = string
  default     = null

  validation {
    condition     = var.ssh_private_key_path == null || !startswith(var.ssh_private_key_path, "~")
    error_message = "The ssh_private_key_path cannot start with ~. Use absolute paths (e.g., /home/user/.ssh/id_ed25519) or relative paths (e.g., ./id_ed25519)."
  }
}

variable "kubeconfig_path" {
  description = "Local path where the kubeconfig file will be copied. Must be an absolute path or relative path (tilde ~ is not supported)."
  type        = string
  default     = "./kubeconfig.yaml"

  validation {
    condition     = !startswith(var.kubeconfig_path, "~")
    error_message = "The kubeconfig_path cannot start with ~. Use absolute paths (e.g., /home/user/kubeconfig.yaml) or relative paths (e.g., ./kubeconfig.yaml)."
  }
}

variable "api_server_domain" {
  description = "Domain name for the Kubernetes API server. If set, the domain will be added to the TLS SANs. This domain should resolve to the load balancer IP."
  type        = string
  default     = null
}
