<!-- BEGIN_TF_DOCS -->
# Terraform Hetzner Cloud RKE2 Infrastructure Module

This Terraform module provisions the infrastructure foundation for an RKE2 Kubernetes cluster on Hetzner Cloud. The module creates the underlying infrastructure components needed for a highly available RKE2 cluster using embedded etcd by default, with Kubernetes applications deployed separately.

## Features

- **High Availability**: Multiple control plane nodes with embedded etcd (or optional external datastore)
- **Hetzner Cloud Integration**: Native support for Hetzner Cloud services (Load Balancer, Networking, etc.)
- **Security**: Firewall rules, private networking, and secure access controls
- **Infrastructure Focus**: Provisions servers, networking - applications deployed separately
- **Cloud-Init**: Automated node provisioning and RKE2 installation
- **Optional External Datastore**: Support for external PostgreSQL-compatible datastore if needed

## Architecture

The module creates the infrastructure foundation:
- Hetzner Cloud private network and subnet
- Control plane nodes (a map with per-node type and location) with RKE2 server
- Worker nodes (configurable count) with RKE2 agent
- Load balancer for Kubernetes API server
- Embedded etcd by default (optional external datastore support)
- Firewall rules for secure access
- **Note**: Kubernetes applications (cert-manager, external-dns, Rancher) are deployed separately

## Usage

```hcl
module "rke2_cluster" {
  source = "git::https://github.com/reddevs-io/terraform-hcloud-rke2?ref=2.0.0"

  hcloud_token = var.hcloud_token
  rke2_token   = var.rke2_token

  cluster_name = "my-rke2-cluster"

  # Control planes are a map keyed by short name. Server and node names become
  # <cluster_name>-control-<key>. Exactly one node initialises the cluster.
  control_plane_server_type = "cx23"
  control_plane_location    = "nbg1"
  api_lb_location           = "nbg1" # keep the API load balancer where it is
  control_planes = {
    one   = { private_ip = "10.0.1.2", first = true }
    two   = { private_ip = "10.0.1.3" }
    three = { private_ip = "10.0.1.4", server_type = "cpx32", location = "hel1" }
  }

  # Worker configuration
  cluster_server_names_worker = ["worker-1", "worker-2"]
  private_ips_workers         = ["10.0.1.11", "10.0.1.12"]
  nb_worker_servers           = 2
  worker_location             = "nbg1"

  # Pin the RKE2 version installed by cloud-init (otherwise the channel head)
  rke2_version = "v1.35.1+rke2r1"

  # SSH access (disabled by default)
  ssh_allowed_ips = ["0.0.0.0/0"]

  # Optional: External datastore (uses embedded etcd if not provided)
  # datastore_endpoint = "postgres://user:password@host:5432/dbname"
}
```

### Bootstrap modes

Each control plane entry accepts `bootstrap = "cloud-init"` (default) or
`bootstrap = "external"`:

- `cloud-init`: user data installs RKE2 and starts `rke2-server`. The node with
  `first = true` initialises the cluster; the others join through the load
  balancer's private IP and retry until it answers.
- `external`: user data only installs base packages. Use this when another tool
  (for example Ansible) performs the join, so that node-local settings such as
  kubelet arguments, datastore shims or version pinning live in one place.

`user_data` is ignored after creation on every server, so editing the
templates, `rke2_version` or `datastore_endpoint` never replaces running nodes.
Recreate a node deliberately with `tofu apply -replace=<address>`.

### Replacing a control plane node

1. Add a new entry to `control_planes` (new key, new private IP) and apply. The
   new server is attached to the network and registered as a load balancer
   target; it receives no traffic until RKE2 answers on ports 6443 and 9345.
2. Join it (cloud-init does this automatically; with `bootstrap = "external"`
   run your join tooling), then verify `kubectl get nodes`.
3. Drain and delete the old node from Kubernetes, remove its entry from
   `control_planes`, and apply again.

## Upgrading from 1.x to 2.0.0

Version 2.0.0 replaces the count-based control plane inputs
(`cluster_server_names_cp`, `private_ips_cp`, `nb_cp_additional_servers`) with
the `control_planes` map, adds `api_lb_location`, `rke2_version` and the
`bootstrap` mode, and requires hcloud provider `~> 1.68` (older providers no
longer read the `location` of existing servers and would replace them all).

Migrate an existing cluster without recreating anything by adding `moved`
blocks in the root module, one per existing node, then run `init -upgrade` and
check that the plan shows no server to add or destroy:

```hcl
moved {
  from = module.rke2_cluster.hcloud_server.control_plane_first
  to   = module.rke2_cluster.hcloud_server.control_plane["one"]
}
moved {
  from = module.rke2_cluster.hcloud_server.control_plane_additional[0]
  to   = module.rke2_cluster.hcloud_server.control_plane["two"]
}
# Repeat for hcloud_server_network.control_plane_first_network /
# control_plane_additional_network[N] -> hcloud_server_network.control_plane["<key>"]
# and hcloud_load_balancer_target.api_server_first /
# api_server_additional[N] -> hcloud_load_balancer_target.control_plane["<key>"]
```

The map keys must equal the old name suffixes (`<cluster_name>-control-<key>`)
so that server names stay unchanged.

## Retrieving Kubeconfig

After successful deployment, retrieve the admin kubeconfig from the first control plane node using the command from the `kubeconfig_command` output:

```bash
# Use the command from kubeconfig_command output
scp root@<control-plane-ip>:/etc/rancher/rke2/rke2.yaml ./kubeconfig.yaml

# Or with SSH key
scp -i <path-to-ssh-key> root@<control-plane-ip>:/etc/rancher/rke2/rke2.yaml ./kubeconfig.yaml

# Use the kubeconfig
export KUBECONFIG=./kubeconfig.yaml
kubectl get nodes
```

## Examples

- [Basic Usage](./examples/basic/) - Simple RKE2 infrastructure setup

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | ~> 1.68 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.68.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_firewall.worker](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_load_balancer.api_server](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer_network.api_server](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_network) | resource |
| [hcloud_load_balancer_service.api_server](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.rke_supervisor_api](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_target.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
| [hcloud_network.rke2_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.rke2_subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_placement_group.cp_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_placement_group.worker_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_server.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server.workers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server_network.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server_network) | resource |
| [hcloud_server_network.worker_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server_network) | resource |
| [hcloud_ssh_key.rke2_key](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_lb_location"></a> [api\_lb\_location](#input\_api\_lb\_location) | Location of the Kubernetes API load balancer. Defaults to `control_plane_location`. Set it explicitly before moving control planes to another location: the load balancer cannot move without being replaced, which changes its IPs. | `string` | `null` | no |
| <a name="input_api_server_domain"></a> [api\_server\_domain](#input\_api\_server\_domain) | Domain name for the Kubernetes API server. If set, the domain will be added to the TLS SANs. This domain should resolve to the load balancer IP. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the RKE2 cluster | `string` | `"rke2-cluster"` | no |
| <a name="input_cluster_server_names_worker"></a> [cluster\_server\_names\_worker](#input\_cluster\_server\_names\_worker) | List of worker node server names | `list(string)` | n/a | yes |
| <a name="input_control_plane_location"></a> [control\_plane\_location](#input\_control\_plane\_location) | Default Hetzner location for control plane nodes (overridable per node in `control_planes`) | `string` | `"nbg1"` | no |
| <a name="input_control_plane_server_type"></a> [control\_plane\_server\_type](#input\_control\_plane\_server\_type) | Default server type for control plane nodes (overridable per node in `control_planes`) | `string` | `"cx22"` | no |
| <a name="input_control_planes"></a> [control\_planes](#input\_control\_planes) | Control plane nodes keyed by short name. The Hetzner server is named<br/>`<cluster_name>-control-<key>`, which RKE2 also uses as the node name.<br/><br/>- `private_ip`  : address in `subnet_cidr` (required)<br/>- `server_type` : defaults to `control_plane_server_type`<br/>- `location`    : defaults to `control_plane_location`<br/>- `first`       : exactly one node must be `true` when bootstrapping a new<br/>                  cluster with `bootstrap = "cloud-init"`; it initialises<br/>                  the cluster and the others join through the load balancer<br/>- `bootstrap`   : `cloud-init` installs and starts RKE2 from user data;<br/>                  `external` only installs base packages so that an<br/>                  external tool (for example Ansible) performs the join<br/>- `labels`      : extra Hetzner labels merged with `node-type = control-plane` | <pre>map(object({<br/>    private_ip  = string<br/>    server_type = optional(string)<br/>    location    = optional(string)<br/>    first       = optional(bool, false)<br/>    bootstrap   = optional(string, "cloud-init")<br/>    labels      = optional(map(string), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_datastore_endpoint"></a> [datastore\_endpoint](#input\_datastore\_endpoint) | External datastore endpoint URL for RKE2 (e.g. postgres://user:password@host:5432/dbname). If not set, RKE2 will use the embedded etcd. Only used by nodes with `bootstrap = "cloud-init"`. | `string` | `null` | no |
| <a name="input_enable_ssh_access"></a> [enable\_ssh\_access](#input\_enable\_ssh\_access) | Enable SSH access rules in firewall (port 22) | `bool` | `false` | no |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Hetzner Cloud API Token | `string` | n/a | yes |
| <a name="input_nb_worker_servers"></a> [nb\_worker\_servers](#input\_nb\_worker\_servers) | Number of worker nodes in the RKE2 cluster | `number` | n/a | yes |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | CIDR block for the private network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_zone"></a> [network\_zone](#input\_network\_zone) | Network zone for the subnet | `string` | `"eu-central"` | no |
| <a name="input_private_ips_workers"></a> [private\_ips\_workers](#input\_private\_ips\_workers) | List of worker nodes private IPs | `list(string)` | n/a | yes |
| <a name="input_rke2_channel"></a> [rke2\_channel](#input\_rke2\_channel) | The RKE2 channel to use for installation (e.g. stable, latest, v1.28). Ignored when `rke2_version` is set. | `string` | `"stable"` | no |
| <a name="input_rke2_token"></a> [rke2\_token](#input\_rke2\_token) | RKE2 cluster token | `string` | n/a | yes |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | Exact RKE2 version to install from cloud-init (e.g. v1.35.1+rke2r1). Pin this on existing clusters so that new nodes match the running version instead of the channel head. | `string` | `null` | no |
| <a name="input_server_image"></a> [server\_image](#input\_server\_image) | Server image to use | `string` | `"ubuntu-24.04"` | no |
| <a name="input_ssh_allowed_ips"></a> [ssh\_allowed\_ips](#input\_ssh\_allowed\_ips) | List of IPs allowed to SSH | `list(string)` | n/a | yes |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to the SSH private key file corresponding to the public key. Must be an absolute path or relative path (tilde ~ is not supported). | `string` | `null` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to the SSH public key file to be used for server access. Must be an absolute path or relative path (tilde ~ is not supported). | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR block for the subnet | `string` | `"10.0.1.0/24"` | no |
| <a name="input_worker_location"></a> [worker\_location](#input\_worker\_location) | Hetzner location for worker nodes | `string` | `"nbg1"` | no |
| <a name="input_worker_server_type"></a> [worker\_server\_type](#input\_worker\_server\_type) | Server type for worker nodes | `string` | `"cx22"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_server_lb_ip"></a> [api\_server\_lb\_ip](#output\_api\_server\_lb\_ip) | Load balancer public IP for Kubernetes API |
| <a name="output_api_server_lb_private_ip"></a> [api\_server\_lb\_private\_ip](#output\_api\_server\_lb\_private\_ip) | Load balancer private IP (RKE2 nodes join through https://<ip>:9345) |
| <a name="output_control_plane_ids"></a> [control\_plane\_ids](#output\_control\_plane\_ids) | Hetzner server IDs of control plane nodes keyed by server name |
| <a name="output_control_plane_ips"></a> [control\_plane\_ips](#output\_control\_plane\_ips) | Public IP addresses of control plane nodes keyed by server name |
| <a name="output_control_plane_private_ips"></a> [control\_plane\_private\_ips](#output\_control\_plane\_private\_ips) | Private IP addresses of control plane nodes keyed by server name |
| <a name="output_first_control_plane_private_ip"></a> [first\_control\_plane\_private\_ip](#output\_first\_control\_plane\_private\_ip) | Private IP of the first control plane node |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | Command to get kubeconfig from the first control plane node |
| <a name="output_private_network_cidr"></a> [private\_network\_cidr](#output\_private\_network\_cidr) | Private network CIDR |
| <a name="output_private_network_id"></a> [private\_network\_id](#output\_private\_network\_id) | Hetzner Cloud private network ID |
| <a name="output_ssh_key_name"></a> [ssh\_key\_name](#output\_ssh\_key\_name) | Name of the SSH key in Hetzner Cloud |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Hetzner Cloud subnet ID |
| <a name="output_worker_ips"></a> [worker\_ips](#output\_worker\_ips) | Public IP addresses of worker nodes |

## Contributing

Please read the contribution guidelines before submitting pull requests.

## License

This module is licensed under the MIT License.
<!-- END_TF_DOCS -->