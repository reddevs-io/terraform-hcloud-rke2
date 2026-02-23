# Progress

This file tracks the project's progress using a task list format.

## Completed Tasks

### Infrastructure Foundation
- [x] Terraform project structure established
- [x] Provider configuration (hcloud, tls)
- [x] Input variables defined with descriptions
- [x] Module outputs defined

### Networking
- [x] Private network resource (`hcloud_network.rke2_network`)
- [x] Subnet resource (`hcloud_network_subnet.rke2_subnet`)
- [x] Control-plane firewall with RKE2 port rules
- [x] Worker firewall with RKE2 port rules + HTTP/HTTPS

### Compute
- [x] SSH key generation via TLS provider
- [x] SSH key upload to Hetzner Cloud
- [x] Placement groups for HA (spread strategy)
- [x] First control-plane server (cluster initializer)
- [x] Additional control-plane servers (count-based)
- [x] Worker servers (count-based)
- [x] Server network attachments with static IPs

### Load Balancer
- [x] Hetzner Load Balancer resource
- [x] Load balancer network attachment
- [x] Kubernetes API service (port 6443)
- [x] RKE supervisor API service (port 9345)
- [x] Load balancer targets for all control-plane nodes

### Embedded Etcd (Default)
- [x] Default to embedded etcd for simplicity
- [x] Optional external datastore support via `datastore_endpoint`
- [x] Cloud-init template with conditional datastore configuration

### Cloud-Init
- [x] Control-plane template with:
  - [x] Optional external datastore configuration
  - [x] Cluster token injection
  - [x] Node IP configuration
  - [x] TLS SANs for load balancer
  - [x] External cloud provider setup
  - [x] Canal CNI interface configuration
- [x] Worker template with:
  - [x] Cluster join configuration
  - [x] External cloud provider setup

### Documentation
- [x] README.md (auto-generated via terraform-docs)
- [x] `.terraform-docs.yml` configuration
- [x] Basic example (`examples/basic/`)
- [x] SSH-disabled example (`examples/ssh-disabled/`)

## Current Tasks

- [ ] Testing and validation of deployed infrastructure
- [ ] Variable validation blocks for input constraints
- [ ] Documentation refinement with inline comments

### Recently Completed
- [x] Removed hardcoded api_server_domain (2026-02-23)
  - Added optional `api_server_domain` variable to `variables.tf`
  - Updated locals in `servers.tf` to use variable (defaults to empty string)
  - Removed hardcoded `reddevs.io` domain suffix
  - Regenerated README.md and examples/basic/README.md
- [x] Documentation updates for kubeconfig export (2026-02-23)
  - Updated `.terraform-docs.yml` with current architecture
  - Regenerated root README.md with terraform-docs
  - Added "Kubeconfig Export" section to README
  - Updated examples/basic/README.md with kubeconfig documentation
- [x] Kubeconfig export functionality (2026-02-23)
- [x] Security fixes for kubeconfig export (2026-02-23)
  - SSH key now written via `local_sensitive_file` instead of shell interpolation
  - Host key verification enabled for kubeconfig retrieval
  - Plan-time error fixed with `try()` for kubeconfig content
  - Output path now uses `var.kubeconfig_path`

## Next Steps

### Short Term
1. Add Terraform tests for infrastructure validation
2. Add variable validation for:
   - `network_cidr` / `subnet_cidr` (valid CIDR format)
   - `server_location` (valid Hetzner location)
   - `server_type` (valid Hetzner server type)
3. Add inline code comments explaining design decisions

### Medium Term
1. Add Hetzner CCM (Cloud Controller Manager) manifest
2. Add Hetzner CSI (Container Storage Interface) driver manifest
3. Consider multi-AZ RDS for datastore HA
4. Add more usage examples

### Long Term
1. Terraform Registry publication preparation
2. Autoscaling integration (cluster-autoscaler)
3. Multi-region support evaluation

## Known Gaps / TODOs

### No TODO/FIXME Comments Found

No explicit TODO or FIXME comments were found in the source files during analysis.

### Implicit Gaps

| Gap | Location | Description |
|-----|----------|-------------|
| No tests | N/A | No `.tftest.hcl` files or test directory |
| SSH disabled by default | `variables.tf:76` | `enable_ssh_access` defaults to `false` |
| No variable validation | `variables.tf` | Only `ssh_key_algorithm` has validation |

## Testing Status

| Test Type | Status |
|-----------|--------|
| Terraform validate | Not verified |
| Terraform plan | Not verified |
| Terraform test | Not implemented |
| End-to-end deployment | Not verified |

## Documentation Status

| Document | Status | Notes |
|----------|--------|-------|
| README.md | Complete | Auto-generated via terraform-docs |
| Variable descriptions | Complete | All variables have descriptions |
| Output descriptions | Complete | All outputs have descriptions |
| Inline code comments | Minimal | Could benefit from more context |
| Usage examples | Partial | Basic example complete, more needed |

---

*Last updated: 2026-02-23 21:15:00 CET*
