# Active Context

This file tracks the project's current status, including recent changes, current goals, and open questions.

## Current Focus

Completing core module functionality for HA RKE2 cluster deployment on Hetzner Cloud:

1. **HA Control Plane**: Multiple control-plane nodes with embedded etcd (optional external datastore)
2. **Worker Node Pools**: Configurable worker count with proper bootstrap sequence
3. **Private Networking**: Hetzner network + subnet with firewall rules

## What Is Working

Based on the existing `.tf` files, the following components are implemented:

### Network Infrastructure
- [x] Private network creation (`hcloud_network.rke2_network`)
- [x] Subnet creation (`hcloud_network_subnet.rke2_subnet`)
- [x] Control-plane firewall with RKE2-required ports
- [x] Worker firewall with RKE2-required ports + HTTP/HTTPS

### Compute Resources
- [x] SSH key generation (TLS provider + hcloud SSH key)
- [x] Placement groups for control-plane and workers (spread strategy)
- [x] First control-plane server (cluster initializer)
- [x] Additional control-plane servers (count-based)
- [x] Worker servers (count-based)
- [x] Server network attachments with static IPs

### Load Balancer
- [x] Hetzner Load Balancer (lb11 type)
- [x] Load balancer network attachment
- [x] API server service (port 6443)
- [x] RKE supervisor API service (port 9345)
- [x] Load balancer targets for all control-plane nodes

### External Datastore (Optional)
- [x] Optional external datastore support via `datastore_endpoint` variable
- [x] Embedded etcd used by default when no external datastore provided
- [x] Cloud-init template with conditional datastore configuration

### Cloud-Init Bootstrap
- [x] Control-plane template with optional external datastore configuration
- [x] Worker template with cluster join configuration
- [x] Hetzner metadata service integration for instance IDs
- [x] External cloud provider configuration

### Outputs
- [x] Load balancer IP
- [x] Control-plane IPs (map)
- [x] Worker IPs (map)
- [x] Network/subnet IDs
- [x] SSH key outputs (sensitive)

## What Is Being Actively Built / Incomplete

### Known Gaps

1. **No Terraform Tests**: No `.tftest.hcl` files or test directory observed
2. **SSH Access Optional**: `enable_ssh_access` variable exists but defaults to `false`
3. **No Variable Validation**: Most variables lack validation blocks (except `ssh_key_algorithm`)
4. **Hardcoded Domain**: `api_server_domain` uses hardcoded `reddevs.io` suffix in locals

### Potential Improvements Identified

1. **Variable Defaults**: Some variables have no defaults (require explicit values)
2. **Documentation**: README is auto-generated; could use more inline comments
3. **Examples**: Only one complete example (`examples/basic/`); `examples/ssh-disabled/` is minimal

## Recent Decisions

### Embedded vs External Datastore

**Decision**: Default to embedded etcd with optional external datastore support.

**Rationale**:
- Simplifies deployment (no AWS account needed)
- Reduces cost (no RDS instance required)
- Embedded etcd provides HA with multiple control-plane nodes
- External datastore still supported for users who need it

**Implementation**:
- `datastore_endpoint` variable (optional, defaults to null)
- Cloud-init template uses conditional to include datastore-endpoint only when provided
- Removed AWS provider and RDS resources

### First Node Pattern

**Decision**: Provision first control-plane node separately from additional nodes.

**Rationale**:
- First node initializes the cluster (no `server:` directive needed)
- Additional nodes join via load balancer
- Ensures proper bootstrap sequence with `depends_on` chains

### Private IP Pre-Assignment

**Decision**: Use pre-defined private IPs via variables instead of DHCP.

**Rationale**:
- Predictable IP addressing for RKE2 configuration
- Required for `node-ip` and `advertise-address` settings
- Simplifies debugging and documentation

## Open Questions / Issues

1. **External Datastore**: Users can now provide their own external datastore if needed - what connection string format should be documented?
2. **Cloud Provider Integration**: External cloud provider configured but CCM/CSI manifests not included in module
3. **HA Considerations**: With embedded etcd, is 3 control-plane nodes sufficient for HA in production?

## Next Steps

1. **Testing**: Add Terraform tests for validation (`terraform test`)
2. **Validation**: Add variable validation blocks for critical inputs
3. **Documentation**: Add inline comments explaining design decisions
4. **Examples**: Expand examples with more use cases
5. **CCM/CSI**: Consider adding Hetzner Cloud Controller Manager and CSI driver manifests

---

*Last updated: 2026-02-23 14:07:00 CET*
