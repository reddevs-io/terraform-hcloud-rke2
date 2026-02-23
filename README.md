# Terraform Hetzner Cloud RKE2 Infrastructure Module

This Terraform module provisions the infrastructure foundation for an RKE2 Kubernetes cluster on Hetzner Cloud. The module creates the underlying infrastructure components needed for a highly available RKE2 cluster using embedded etcd, with Kubernetes applications deployed separately.

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
- Control plane nodes (configurable count) with RKE2 server
- Worker nodes (configurable count) with RKE2 agent
- Load balancer for Kubernetes API server
- Embedded etcd by default (optional external datastore support)
- Firewall rules for secure access
- **Note**: Kubernetes applications (cert-manager, external-dns, Rancher) are deployed separately

## Usage

```hcl
module "rke2_infrastructure" {
  source = "your-org/rke2/hcloud"
  version = "~> 1.0"

  # Hetzner Cloud Configuration
  hcloud_token = var.hcloud_token
  cluster_name = "my-cluster"
  
  # Server Configuration
  server_type     = "cx32"
  server_location = "nbg1"
  
  # Network Configuration
  network_cidr = "10.0.0.0/16"
  subnet_cidr  = "10.0.1.0/24"
  
  # RKE2 Configuration
  rke2_token = var.rke2_token
  
  # Optional: External datastore (uses embedded etcd if not provided)
  # datastore_endpoint = "postgres://user:password@host:5432/dbname"
}
```

## Examples

- [Basic Usage](./examples/basic/) - Simple RKE2 infrastructure setup

<!-- BEGIN_TF_DOCS -->
# Terraform Hetzner Cloud RKE2 Infrastructure Module

This Terraform module provisions the infrastructure foundation for an RKE2 Kubernetes cluster on Hetzner Cloud. The module creates the underlying infrastructure components needed for a highly available RKE2 cluster using embedded etcd, with Kubernetes applications deployed separately.

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
- Control plane nodes (configurable count) with RKE2 server
- Worker nodes (configurable count) with RKE2 agent
- Load balancer for Kubernetes API server
- Embedded etcd by default (optional external datastore support)
- Firewall rules for secure access
- **Note**: Kubernetes applications (cert-manager, external-dns, Rancher) are deployed separately

## Usage

```hcl
module "rke2_infrastructure" {
  source = "your-org/rke2/hcloud"
  version = "~> 1.0"

  # Hetzner Cloud Configuration
  hcloud_token = var.hcloud_token
  cluster_name = "my-cluster"
  
  # Server Configuration
  server_type     = "cx32"
  server_location = "nbg1"
  
  # Network Configuration
  network_cidr = "10.0.0.0/16"
  subnet_cidr  = "10.0.1.0/24"
  
  # RKE2 Configuration
  rke2_token = var.rke2_token
  
  # Optional: External datastore (uses embedded etcd if not provided)
  # datastore_endpoint = "postgres://user:password@host:5432/dbname"
}
```

## Examples

- [Basic Usage](./examples/basic/) - Simple RKE2 infrastructure setup

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | ~> 1.45 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.52.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.x |

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
| [hcloud_load_balancer_target.api_server_additional](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
| [hcloud_load_balancer_target.api_server_first](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
| [hcloud_network.rke2_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.rke2_subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_placement_group.cp_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_placement_group.worker_placement_group](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/placement_group) | resource |
| [hcloud_server.control_plane_additional](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server.control_plane_first](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server.workers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_server_network.control_plane_additional_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server_network) | resource |
| [hcloud_server_network.control_plane_first_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server_network) | resource |
| [hcloud_server_network.worker_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server_network) | resource |
| [hcloud_ssh_key.rke2_key](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [tls_private_key.rke2_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the RKE2 cluster | `string` | `"uhuru"` | no |
| <a name="input_cluster_server_names_cp"></a> [cluster\_server\_names\_cp](#input\_cluster\_server\_names\_cp) | List of control plane node server names | `list(string)` | <pre>[<br/>  "nkrumah",<br/>  "sankara",<br/>  "nyerere"<br/>]</pre> | no |
| <a name="input_cluster_server_names_worker"></a> [cluster\_server\_names\_worker](#input\_cluster\_server\_names\_worker) | List of worker node server names | `list(string)` | <pre>[<br/>  "kenyatta",<br/>  "machel"<br/>]</pre> | no |
| <a name="input_datastore_endpoint"></a> [datastore\_endpoint](#input\_datastore\_endpoint) | External datastore endpoint URL for RKE2 (e.g. postgres://user:password@host:5432/dbname). If not set, RKE2 will use the embedded etcd. | `string` | `null` | no |
| <a name="input_enable_ssh_access"></a> [enable\_ssh\_access](#input\_enable\_ssh\_access) | Enable SSH access rules in firewall (port 22) | `bool` | `false` | no |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | Hetzner Cloud API Token | `string` | n/a | yes |
| <a name="input_nb_cp_additional_servers"></a> [nb\_cp\_additional\_servers](#input\_nb\_cp\_additional\_servers) | Number of additional control-plane nodes in the RKE2 cluster | `number` | `2` | no |
| <a name="input_nb_worker_servers"></a> [nb\_worker\_servers](#input\_nb\_worker\_servers) | Number of worker nodes in the RKE2 cluster | `number` | `2` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | CIDR block for the private network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_zone"></a> [network\_zone](#input\_network\_zone) | Network zone for the subnet | `string` | `"eu-central"` | no |
| <a name="input_private_ips_cp"></a> [private\_ips\_cp](#input\_private\_ips\_cp) | List of control plane nodes private IPs | `list(string)` | <pre>[<br/>  "10.0.1.2",<br/>  "10.0.1.3",<br/>  "10.0.1.4"<br/>]</pre> | no |
| <a name="input_private_ips_workers"></a> [private\_ips\_workers](#input\_private\_ips\_workers) | List of worker nodes private IPs | `list(string)` | <pre>[<br/>  "10.0.1.5",<br/>  "10.0.1.6"<br/>]</pre> | no |
| <a name="input_rke2_token"></a> [rke2\_token](#input\_rke2\_token) | RKE2 cluster token | `string` | n/a | yes |
| <a name="input_server_image"></a> [server\_image](#input\_server\_image) | Server image to use | `string` | `"ubuntu-24.04"` | no |
| <a name="input_server_location"></a> [server\_location](#input\_server\_location) | Server location | `string` | `"nbg1"` | no |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | Hetzner server type | `string` | `"cx32"` | no |
| <a name="input_ssh_allowed_ips"></a> [ssh\_allowed\_ips](#input\_ssh\_allowed\_ips) | List of IPs allowed to SSH | `list(string)` | <pre>[<br/>  "1.1.1.1/32"<br/>]</pre> | no |
| <a name="input_ssh_key_algorithm"></a> [ssh\_key\_algorithm](#input\_ssh\_key\_algorithm) | Algorithm for SSH key generation | `string` | `"ED25519"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR block for the subnet | `string` | `"10.0.1.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_server_lb_ip"></a> [api\_server\_lb\_ip](#output\_api\_server\_lb\_ip) | Load balancer IP for Kubernetes API |
| <a name="output_control_plane_ips"></a> [control\_plane\_ips](#output\_control\_plane\_ips) | Public IP addresses of control plane nodes |
| <a name="output_first_control_plane_private_ip"></a> [first\_control\_plane\_private\_ip](#output\_first\_control\_plane\_private\_ip) | Private IP of the first control plane node |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | Command to get kubeconfig from first control plane node |
| <a name="output_private_network_cidr"></a> [private\_network\_cidr](#output\_private\_network\_cidr) | Private network CIDR |
| <a name="output_private_network_id"></a> [private\_network\_id](#output\_private\_network\_id) | Hetzner Cloud private network ID |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Hetzner Cloud subnet ID |
| <a name="output_ssh_key_name"></a> [ssh\_key\_name](#output\_ssh\_key\_name) | Name of the SSH key in Hetzner Cloud |
| <a name="output_worker_ips"></a> [worker\_ips](#output\_worker\_ips) | Public IP addresses of worker nodes |

## Contributing

Please read the contribution guidelines before submitting pull requests.

## License

This module is licensed under the MIT License.
<!-- END_TF_DOCS -->
