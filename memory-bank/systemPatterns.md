# System Patterns

This file documents recurring patterns and standards used in the project.

## Module Structure

```
terraform-hetzner-rke2/
├── main.tf              # Provider configuration
├── variables.tf         # Input variable definitions
├── output.tf            # Output definitions
├── network.tf           # Network + firewall resources
├── servers.tf           # Server resources (control-plane + workers)
├── loadbalancer.tf      # Load balancer resources
├── cloud-init/          # Cloud-init templates
│   ├── control-plane.yml
│   └── worker.yml
└── examples/
    └── basic/           # Basic usage example
```

## Resource Grouping Pattern

Resources are organized by functional area:

| File | Purpose |
|------|---------|
| `main.tf` | Provider configuration (hcloud, tls) |
| `variables.tf` | All input variables with descriptions and defaults |
| `network.tf` | `hcloud_network`, `hcloud_network_subnet`, `hcloud_firewall` (control-plane + worker) |
| `servers.tf` | `tls_private_key`, `hcloud_ssh_key`, `hcloud_placement_group`, `hcloud_server`, `hcloud_server_network` |
| `loadbalancer.tf` | `hcloud_load_balancer`, `hcloud_load_balancer_network`, `hcloud_load_balancer_service`, `hcloud_load_balancer_target` |
| `output.tf` | Module outputs for downstream consumption |

## Cloud-Init Approach

### Template Pattern

Cloud-init templates use `templatefile()` function with YAML files:

```hcl
user_data = templatefile("${path.module}/cloud-init/control-plane.yml", {
  node_name          = "${var.cluster_name}-control-${var.cluster_server_names_cp[0]}"
  is_first_node      = true
  cluster_token      = var.rke2_token
  lb_public_ip       = hcloud_load_balancer.api_server.ipv4
  lb_private_ip      = hcloud_load_balancer_network.api_server.ip
  api_domain         = local.api_server_domain
  node_private_ip    = var.private_ips_cp[0]
  datastore_endpoint = var.datastore_endpoint
})
```

### Control-Plane Bootstrap Sequence

1. Install RKE2 via `curl -sfL https://get.rke2.io | sh -`
2. Wait for Hetzner metadata service
3. Generate `/etc/rancher/rke2/config.yaml` with:
   - Optional external datastore endpoint (when provided)
   - Cluster token
   - Node IP configuration (private)
   - TLS SANs (load balancer IPs + optional domain)
   - External cloud provider configuration
4. Configure Canal CNI for private interface
5. Enable and start `rke2-server.service`

### Worker Bootstrap Sequence

1. Install RKE2 agent via `curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -`
2. Wait for Hetzner metadata service
3. Generate `/etc/rancher/rke2/config.yaml` with:
   - Server URL (load balancer private IP:9345)
   - Cluster token
   - External cloud provider configuration
4. Enable and start `rke2-agent.service`

## HA Design Pattern

### Control Plane Topology

```
                    ┌─────────────────────┐
                    │  Hetzner Load       │
                    │  Balancer (lb11)    │
                    │  - Port 6443 (API)  │
                    │  - Port 9345 (Sup)  │
                    └─────────┬───────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Control Plane │   │ Control Plane │   │ Control Plane │
│    Node 1     │   │    Node 2     │   │    Node 3     │
│  (initializer)│   │   (joiner)    │   │   (joiner)    │
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │                   │
        └───────────────────┴───────────────────┘
                            │
                    ┌───────▼───────┐
                    │ Embedded etcd │
                    │   (default)   │
                    └───────────────┘
```

### Key HA Decisions

1. **First Node Pattern**: The first control-plane node is provisioned separately as the cluster initializer (`is_first_node = true`)
2. **Additional Nodes**: Join the cluster via load balancer (no `server:` directive needed for first node)
3. **Embedded Etcd**: Default datastore for HA (optional external datastore support)
4. **Load Balancer Targets**: All control-plane nodes attached to LB using `use_private_ip = true`

## Networking Pattern

### Private Network Architecture

```
Hetzner Cloud Network (10.0.0.0/16)
└── Subnet (10.0.1.0/24)
    ├── Control Plane 1: 10.0.1.2
    ├── Control Plane 2: 10.0.1.3
    ├── Control Plane 3: 10.0.1.4
    ├── Worker 1:        10.0.1.5
    ├── Worker 2:        10.0.1.6
    └── Load Balancer:   (dynamic IP in subnet)
```

### Firewall Rules Pattern

Firewalls are defined separately for control-plane and worker nodes:

**Control-Plane Firewall** (`hcloud_firewall.control_plane`):
- Port 6443: Kubernetes API (network CIDR + 0.0.0.0/0 for external access)
- Port 9345: RKE2 supervisor API (network CIDR only)
- Port 10250: kubelet metrics
- Ports 2379-2381: etcd (legacy, may not be needed with external datastore)
- Ports 30000-32767: NodePort range
- Ports 8472, 51820, 51821: Canal CNI (VXLAN + WireGuard)
- Port 9099: Canal health checks
- Ports 8443, 9443: Admission webhooks

**Worker Firewall** (`hcloud_firewall.worker`):
- Port 10250: kubelet metrics
- Ports 30000-32767: NodePort range
- Ports 80, 443: HTTP/HTTPS for ingress
- Canal CNI ports (same as control-plane)

## Terraform Conventions

### Resource Naming

- Pattern: `${var.cluster_name}-${resource-type}-${suffix}`
- Examples: `uhuru-network`, `uhuru-api-lb`, `uhuru-control-plane-fw`

### Node Naming

- Control-plane: `${var.cluster_name}-control-${var.cluster_server_names_cp[index]}`
- Workers: `${var.cluster_name}-worker-${var.cluster_server_names_worker[index]}`

### Count vs For_Each

- `count` used for homogeneous node pools (workers, additional control-plane nodes)
- Static IP assignment via list indexing (`var.private_ips_cp[count.index + 1]`)

### Placement Groups

- Separate spread placement groups for control-plane and workers
- Ensures nodes are distributed across physical hosts for HA

### Dependency Management

- Explicit `depends_on` for ordering:
  - Control-plane nodes depend on network subnet
  - Additional control-plane nodes depend on first node's network attachment
  - Workers depend on all control-plane nodes being network-attached
  - Load balancer targets depend on server network attachments

## Outputs Pattern

Outputs provide essential information for downstream consumption:

```hcl
output "api_server_lb_ip" {
  description = "Load balancer IP for Kubernetes API"
  value       = hcloud_load_balancer.api_server.ipv4
}

output "control_plane_ips" {
  description = "Public IP addresses of control plane nodes"
  value = merge(
    { (hcloud_server.control_plane_first.name) = hcloud_server.control_plane_first.ipv4_address },
    { for i, server in hcloud_server.control_plane_additional : server.name => server.ipv4_address }
  )
}
```

---

*Last updated: 2026-02-23 14:05:00 CET*
