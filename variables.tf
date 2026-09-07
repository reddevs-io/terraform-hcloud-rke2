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

# -----------------------------------------------------------------------------
# Control plane nodes
# -----------------------------------------------------------------------------

variable "control_planes" {
  description = <<-EOT
    Control plane nodes keyed by short name. The Hetzner server is named
    `<cluster_name>-control-<key>`, which RKE2 also uses as the node name.

    - `private_ip`  : address in `subnet_cidr` (required)
    - `server_type` : defaults to `control_plane_server_type`
    - `location`    : defaults to `control_plane_location`
    - `first`       : exactly one node must be `true` when bootstrapping a new
                      cluster with `bootstrap = "cloud-init"`; it initialises
                      the cluster and the others join through the load balancer
    - `bootstrap`   : `cloud-init` installs and starts RKE2 from user data;
                      `external` only installs base packages so that an
                      external tool (for example Ansible) performs the join
    - `labels`      : extra Hetzner labels merged with `node-type = control-plane`
  EOT
  type = map(object({
    private_ip  = string
    server_type = optional(string)
    location    = optional(string)
    first       = optional(bool, false)
    bootstrap   = optional(string, "cloud-init")
    labels      = optional(map(string), {})
  }))

  validation {
    condition     = length(var.control_planes) > 0
    error_message = "At least one control plane node must be defined."
  }

  validation {
    condition     = length([for k, v in var.control_planes : k if v.first]) <= 1
    error_message = "At most one control plane node may set first = true."
  }

  validation {
    condition     = alltrue([for k, v in var.control_planes : contains(["cloud-init", "external"], v.bootstrap)])
    error_message = "control_planes[*].bootstrap must be \"cloud-init\" or \"external\"."
  }

  validation {
    condition     = length(distinct([for k, v in var.control_planes : v.private_ip])) == length(var.control_planes)
    error_message = "control_planes[*].private_ip values must be unique."
  }
}

variable "control_plane_server_type" {
  description = "Default server type for control plane nodes (overridable per node in `control_planes`)"
  type        = string
  default     = "cx22"
}

variable "control_plane_location" {
  description = "Default Hetzner location for control plane nodes (overridable per node in `control_planes`)"
  type        = string
  default     = "nbg1"
}

variable "api_lb_location" {
  description = "Location of the Kubernetes API load balancer. Defaults to `control_plane_location`. Set it explicitly before moving control planes to another location: the load balancer cannot move without being replaced, which changes its IPs."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Worker nodes
# -----------------------------------------------------------------------------

variable "cluster_server_names_worker" {
  description = "List of worker node server names"
  type        = list(string)
}

variable "private_ips_workers" {
  description = "List of worker nodes private IPs"
  type        = list(string)
}

variable "nb_worker_servers" {
  description = "Number of worker nodes in the RKE2 cluster"
  type        = number
}

variable "worker_server_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx22"
}

variable "worker_location" {
  description = "Hetzner location for worker nodes"
  type        = string
  default     = "nbg1"
}

# -----------------------------------------------------------------------------
# Shared
# -----------------------------------------------------------------------------

variable "server_image" {
  description = "Server image to use"
  type        = string
  default     = "ubuntu-24.04"
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

variable "datastore_endpoint" {
  description = "External datastore endpoint URL for RKE2 (e.g. postgres://user:password@host:5432/dbname). If not set, RKE2 will use the embedded etcd. Only used by nodes with `bootstrap = \"cloud-init\"`."
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
  description = "Path to the SSH private key file corresponding to the public key. Must be an absolute path or relative path (tilde ~ is not supported)."
  type        = string
  default     = null

  validation {
    # Ternary instead of ||: HCL operators are not short-circuit, so startswith(null, ...) would error.
    condition     = var.ssh_private_key_path == null ? true : !startswith(var.ssh_private_key_path, "~")
    error_message = "The ssh_private_key_path cannot start with ~. Use absolute paths (e.g., /home/user/.ssh/id_ed25519) or relative paths (e.g., ./id_ed25519)."
  }
}

variable "api_server_domain" {
  description = "Domain name for the Kubernetes API server. If set, the domain will be added to the TLS SANs. This domain should resolve to the load balancer IP."
  type        = string
  default     = null
}

variable "rke2_channel" {
  description = "The RKE2 channel to use for installation (e.g. stable, latest, v1.28). Ignored when `rke2_version` is set."
  type        = string
  default     = "stable"
}

variable "rke2_version" {
  description = "Exact RKE2 version to install from cloud-init (e.g. v1.35.1+rke2r1). Pin this on existing clusters so that new nodes match the running version instead of the channel head."
  type        = string
  default     = null
}
