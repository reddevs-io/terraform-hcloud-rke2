# Tech Context

This file documents the technologies, tooling, and technical constraints used in the project.

## Primary Technologies

### OpenTofu (HCL)

- **Version**: `>= 1.2.0`
- **Primary IaC language** for infrastructure provisioning
- **CLI tool**: `tofu` (OpenTofu fork of Terraform)
- Module pattern for reusability

### Hetzner Cloud Provider (`hetznercloud/hcloud`)

- **Version**: `1.52.0` (constraint: `~> 1.45`)
- Resources used:
  - `hcloud_network` - Private network
  - `hcloud_network_subnet` - Subnet within network
  - `hcloud_server` - Virtual machines
  - `hcloud_server_network` - Server-to-network attachment
  - `hcloud_firewall` - Firewall rules
  - `hcloud_load_balancer` - Load balancer
  - `hcloud_load_balancer_network` - LB network attachment
  - `hcloud_load_balancer_service` - LB service (port mapping)
  - `hcloud_load_balancer_target` - LB backend targets
  - `hcloud_ssh_key` - SSH key management
  - `hcloud_placement_group` - Placement groups for HA

## RKE2 (Rancher Kubernetes Engine 2)

- **Kubernetes distribution** bootstrapped via cloud-init
- Installation via official script: `curl -sfL https://get.rke2.io | sh -`
- Configuration via `/etc/rancher/rke2/config.yaml`
- External cloud provider mode enabled (`cloud-provider-name: external`)
- Canal CNI with VXLAN (default)

## Datastore Options

### Embedded Etcd (Default)

- Default datastore for RKE2 clusters
- No additional cost or configuration required
- Provides HA with multiple control-plane nodes

### External Datastore (Optional)

Users can optionally provide their own external PostgreSQL-compatible datastore:
- **Connection**: `postgres://<username>:<password>@<host>:<port>/<database>`
- **Variable**: `datastore_endpoint` (optional, defaults to null)
- When not provided, RKE2 uses embedded etcd

### Connection Pattern

When external datastore is configured:
```
datastore-endpoint: postgres://<username>:<password>@<host>:5432/<database>
```

## Cloud-Init

- **Format**: YAML (`#cloud-config`)
- **Purpose**: Node bootstrap and RKE2 installation
- **Templates**:
  - `cloud-init/control-plane.yml` - Control-plane node configuration
  - `cloud-init/worker.yml` - Worker node configuration

### Key Cloud-Init Features Used

- `package_update` / `package_upgrade` - System updates
- `packages` - Install curl, wget, unzip
- `runcmd` - Shell commands for RKE2 setup

## Supporting Tools

### terraform-docs

- **Purpose**: README generation
- **Configuration**: `.terraform-docs.yml`
- **Output**: Injects documentation between `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` markers
- **Format**: Markdown table

### GitHub Actions

- **Location**: `.github/` directory
- **Purpose**: CI/CD (exact workflows not analyzed)

## Provider Version Constraints

| Provider | Version | Constraint |
|----------|---------|------------|
| tofu (OpenTofu) | >= 1.2.0 | - |
| hcloud | 1.52.0 | ~> 1.45 |

## Technical Constraints

### Hetzner Cloud

- Network zone must match server location region (e.g., `eu-central` for `nbg1`)
- Load balancer must be in same location as servers
- Private IPs must be within subnet CIDR and pre-assigned

### RKE2

- First node must initialize cluster before additional nodes join
- Token must be consistent across all nodes
- External datastore URL must be accessible from all control-plane nodes (if used)

## Development Environment

- **Shell**: zsh
- **OS**: Linux 6.17
- **Working Directory**: `/home/franmako/www/terraform-hetzner-rke2`
- **IaC Tool**: OpenTofu (`tofu`)

---

*Last updated: 2026-02-23 21:33:00 CET*
