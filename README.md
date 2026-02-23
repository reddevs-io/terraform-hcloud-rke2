<!-- BEGIN_TF_DOCS -->
# Terraform Hetzner Cloud RKE2 Infrastructure Module

This Terraform module provisions the infrastructure foundation for an RKE2 Kubernetes cluster on Hetzner Cloud. The module creates the underlying infrastructure components needed for a highly available RKE2 cluster using embedded etcd by default, with Kubernetes applications deployed separately.

## Features

- **High Availability**: Multiple control plane nodes with embedded etcd (or optional external datastore)
- **Hetzner Cloud Integration**: Native support for Hetzner Cloud services (Load Balancer, Networking, etc.)
- **Security**: Firewall rules, private networking, and secure access controls
- **Infrastructure Focus**: Provisions servers, networking - applications deployed separately
- **Cloud-Init**: Automated node provisioning and RKE2 installation
- **Kubeconfig Export**: Automatic kubeconfig retrieval after cluster provisioning
- **Optional External Datastore**: Support for external PostgreSQL-compatible datastore if needed

## Architecture

The module creates the infrastructure foundation:
- Hetzner Cloud private network and subnet
- Control plane nodes (configurable count) with RKE2 server
- Worker nodes (configurable count) with RKE2 agent
- Load balancer for Kubernetes API server
- Embedded etcd by default (optional external datastore support)
- Firewall rules for secure access
- **Note**: Kubernetes applications (cert-manager, external-dns, Rancher) are deployed separately

## Usage

```hcl
module "rke2_cluster" {
  source = "github.com/FranMako/terraform-hetzner-rke2"

  hcloud_token = var.hcloud_token
  rke2_token   = var.rke2_token

  cluster_name = "my-rke2-cluster"

  # Control plane configuration
  cluster_server_names_cp   = ["cp-1", "cp-2", "cp-3"]
  private_ips_cp            = ["10.0.1.1", "10.0.1.2", "10.0.1.3"]
  nb_cp_additional_servers  = 2

  # Worker configuration
  cluster_server_names_worker = ["worker-1", "worker-2"]
  private_ips_workers         = ["10.0.1.11", "10.0.1.12"]
  nb_worker_servers           = 2
  worker_location             = "nbg1"

  # SSH access (disabled by default)
  ssh_allowed_ips = ["0.0.0.0/0"]

  # Optional: External datastore (uses embedded etcd if not provided)
  # datastore_endpoint = "postgres://user:password@host:5432/dbname"
}
```

## Kubeconfig Export

After successful deployment, the module automatically retrieves the admin kubeconfig from the first control plane node:

- The kubeconfig is saved to the path specified by `kubeconfig_path` (default: `./kubeconfig.yaml`)
- The `kubeconfig` output contains the kubeconfig content (sensitive value)
- The `kubeconfig_command` output shows the manual command to retrieve kubeconfig if needed

```bash
# Use the exported kubeconfig
export KUBECONFIG=./kubeconfig.yaml
kubectl get nodes
```

## Examples

- [Basic Usage](./examples/basic/) - Simple RKE2 infrastructure setup

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | 1.52.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.52.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.7.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.control_plane](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/firewall) | resource |
| [hcloud_firewall.worker](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/firewall) | resource |
| [hcloud_load_balancer.api_server](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer_network.api_server](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/load_balancer_network) | resource |
| [hcloud_load_balancer_service.api_server](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.rke_supervisor_api](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_target.api_server_additional](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/load_balancer_target) | resource |
| [hcloud_load_balancer_target.api_server_first](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/load_balancer_target) | resource |
| [hcloud_network.rke2_network](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/network) | resource |
| [hcloud_network_subnet.rke2_subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/network_subnet) | resource |
| [hcloud_placement_group.cp_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/placement_group) | resource |
| [hcloud_placement_group.worker_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/placement_group) | resource |
| [hcloud_server.control_plane_additional](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/server) | resource |
| [hcloud_server.control_plane_first](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/server) | resource |
| [hcloud_server.workers](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/server) | resource |
| [hcloud_server_network.control_plane_additional_network](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/server_network) | resource |
| [hcloud_server_network.control_plane_first_network](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/server_network) | resource |
| [hcloud_server_network.worker_network](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/server_network) | resource |
| [hcloud_ssh_key.rke2_key](https://registry.terraform.io/providers/hetznercloud/hcloud/1.52.0/docs/resources/ssh_key) | resource |
| [local_sensitive_file.ssh_key_for_kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [null_resource.capture_host_key](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.cleanup_temp_files](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.kubeconfig_export](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.ssh_key_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_server_domain"></a> [api\_server\_domain](#input\_api\_server\_domain) | Domain name for the Kubernetes API server. If set, the domain will be added to the TLS SANs. This domain should resolve to the load balancer IP. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the RKE2 cluster | `string` | `"rke2-cluster"` | no |
| <a name="input_cluster_server_names_cp"></a> [cluster\_server\_names\_cp](#input\_cluster\_server\_names\_cp) | List of control plane node server names | `list(string)` | n/a | yes |
| <a name="input_cluster_server_names_worker"></a> [cluster\_server\_names\_worker](#input\_cluster\_server\_names\_worker) | List of worker node server names | `list(string)` | n/a | yes |
| <a name="input_control_plane_location"></a> [control\_plane\_location](#input\_control\_plane\_location) | Hetzner location for control plane nodes | `string` | `"nbg1"` | no |
| <a name="input_control_plane_server_type"></a> [control\_plane\_server\_type](#input\_control\_plane\_server\_type) | Server type for control plane nodes | `string` | `"cx22"` | no |
| <a name="input_datastore_endpoint"></a> [datastore\_endpoint](#input\_datastore\_endpoint) | External datastore endpoint URL for RKE2 (e.g. postgres://user:password@host:5432/dbname). If not set, RKE2 will use the embedded etcd. | `string` | `null` | no |
| <a name="input_enable_ssh_access"></a> [enable\_ssh\_access](#input\_enable\_ssh\_access) | Enable SSH access rules in firewall (port 22) | `bool` | `false` | no |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Hetzner Cloud API Token | `string` | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Local path where the kubeconfig file will be copied. Must be an absolute path or relative path (tilde ~ is not supported). | `string` | `"./kubeconfig.yaml"` | no |
| <a name="input_nb_cp_additional_servers"></a> [nb\_cp\_additional\_servers](#input\_nb\_cp\_additional\_servers) | Number of additional control-plane nodes in the RKE2 cluster | `number` | n/a | yes |
| <a name="input_nb_worker_servers"></a> [nb\_worker\_servers](#input\_nb\_worker\_servers) | Number of worker nodes in the RKE2 cluster | `number` | n/a | yes |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | CIDR block for the private network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_zone"></a> [network\_zone](#input\_network\_zone) | Network zone for the subnet | `string` | `"eu-central"` | no |
| <a name="input_private_ips_cp"></a> [private\_ips\_cp](#input\_private\_ips\_cp) | List of control plane nodes private IPs | `list(string)` | n/a | yes |
| <a name="input_private_ips_workers"></a> [private\_ips\_workers](#input\_private\_ips\_workers) | List of worker nodes private IPs | `list(string)` | n/a | yes |
| <a name="input_rke2_token"></a> [rke2\_token](#input\_rke2\_token) | RKE2 cluster token | `string` | n/a | yes |
| <a name="input_server_image"></a> [server\_image](#input\_server\_image) | Server image to use | `string` | `"ubuntu-24.04"` | no |
| <a name="input_ssh_allowed_ips"></a> [ssh\_allowed\_ips](#input\_ssh\_allowed\_ips) | List of IPs allowed to SSH | `list(string)` | n/a | yes |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to the SSH private key file corresponding to the public key. Required when enable\_ssh\_access is true for kubeconfig retrieval. | `string` | `null` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to the SSH public key file to be used for server access | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR block for the subnet | `string` | `"10.0.1.0/24"` | no |
| <a name="input_worker_location"></a> [worker\_location](#input\_worker\_location) | Hetzner location for worker nodes | `string` | `"nbg1"` | no |
| <a name="input_worker_server_type"></a> [worker\_server\_type](#input\_worker\_server\_type) | Server type for worker nodes | `string` | `"cx22"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_server_lb_ip"></a> [api\_server\_lb\_ip](#output\_api\_server\_lb\_ip) | Load balancer IP for Kubernetes API |
| <a name="output_control_plane_ips"></a> [control\_plane\_ips](#output\_control\_plane\_ips) | Public IP addresses of control plane nodes |
| <a name="output_first_control_plane_private_ip"></a> [first\_control\_plane\_private\_ip](#output\_first\_control\_plane\_private\_ip) | Private IP of the first control plane node |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Admin kubeconfig content for the RKE2 cluster (only available when enable\_ssh\_access and ssh\_private\_key\_path are set) |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | Command to get kubeconfig from first control plane node |
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