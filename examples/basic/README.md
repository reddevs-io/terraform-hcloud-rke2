# Basic RKE2 Infrastructure Example

This example demonstrates how to provision the infrastructure for an RKE2 Kubernetes cluster on Hetzner Cloud using the terraform-hcloud-rke2 module.

## Architecture

This example creates the infrastructure foundation:
- 2 control plane nodes (1 initial + 1 additional) with RKE2 server
- 2 worker nodes with RKE2 agent
- AWS RDS PostgreSQL as external datastore
- Hetzner Cloud Load Balancer for API server
- Private network with firewall rules
- **Note**: Kubernetes applications (cert-manager, external-dns, Rancher) are deployed separately

## Prerequisites

1. **Hetzner Cloud Account**: Create an account and generate an API token
2. **AWS Account**: For RDS PostgreSQL instance
3. **Terraform**: Version >= 1.2.0

## Setup Instructions

### 1. Clone and Navigate

```bash
git clone <your-repo>
cd terraform-hcloud-rke2/examples/basic
```

### 2. Configure Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your actual values:

```hcl
# Required: Hetzner Cloud API token
hcloud_token = "your-hetzner-cloud-api-token"

# Required: AWS RDS connection string
external_datastore_url = "postgres://username:password@your-rds-endpoint:5432/database"

# Security: Replace with your actual IP
ssh_allowed_ips = ["YOUR.IP.ADDRESS.HERE/32"]

# Optional: Customize cluster configuration
cluster_name = "my-rke2-cluster"
server_type = "cx22"
nb_cp_additional_servers = 1
nb_worker_servers = 2
```

### 3. Initialize and Plan

```bash
terraform init
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

The deployment will take approximately 10-15 minutes.

### 5. Access Your Cluster

After deployment, get the kubeconfig:

```bash
# Use the command from terraform output
terraform output kubeconfig_command
# Example: scp root@<ip>:/etc/rancher/rke2/rke2.yaml ./kubeconfig.yaml

# Configure kubectl
export KUBECONFIG=./kubeconfig.yaml
kubectl get nodes
```

## Outputs

| Name | Description |
|------|-------------|
| `api_server_lb_ip` | Load balancer IP for Kubernetes API |
| `control_plane_ips` | Public IP addresses of control plane nodes |
| `worker_ips` | Public IP addresses of worker nodes |
| `kubeconfig_command` | Command to retrieve kubeconfig |
| `first_control_plane_private_ip` | Private IP of the first control plane node |
| `private_network_cidr` | Private network CIDR |
| `private_network_id` | Hetzner Cloud private network ID |
| `subnet_id` | Hetzner Cloud subnet ID |
| `rds_endpoint` | RDS instance endpoint |
| `rds_port` | RDS instance port |
| `rds_database_name` | RDS database name |
| `rke2_token` | Generated RKE2 cluster token (sensitive) |

## Customization

### Scaling

To change the number of nodes, modify these variables:

```hcl
nb_cp_additional_servers = 2  # Total control plane: 3 (1 + 2 additional)
nb_worker_servers        = 3  # Total workers: 3
```

### Server Types

Change server specifications:

```hcl
server_type = "cx32"  # More powerful servers
```

Available server types: `cx22`, `cx32`, `cx42`, `cx52`, etc.

### Locations

Deploy in different regions:

```hcl
server_location = "fsn1"  # Falkenstein
network_zone    = "eu-central"
```

## Security Considerations

1. **SSH Access**: Restrict `ssh_allowed_ips` to your actual IP addresses
2. **RDS Access**: Configure `allowed_cidr` appropriately
3. **API Tokens**: Store tokens securely (use environment variables or secret management)
4. **Firewall**: Review and customize firewall rules as needed

## Troubleshooting

### Common Issues

1. **RDS Connection**: Ensure the RDS instance is accessible from Hetzner Cloud
2. **SSH Access**: Verify your IP is correctly configured in `ssh_allowed_ips`
3. **Server Provisioning**: Check cloud-init logs if servers fail to start properly

### Logs

Check cloud-init logs on servers:

```bash
ssh root@<server-ip>
tail -f /var/log/cloud-init-output.log
```

### RKE2 Status

Check RKE2 service status:

```bash
ssh root@<control-plane-ip>
systemctl status rke2-server
journalctl -u rke2-server -f
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources including the RDS database.

## Cost Estimation

Approximate monthly costs (as of 2024):
- Hetzner servers (2x cx22 + 2x cx22): ~€40-50
- Hetzner Load Balancer: ~€5
- AWS RDS (db.t3.micro): ~$15-20 (Free Tier eligible)
- **Total**: ~€50-70/month

## Next Steps

- Configure monitoring with Prometheus/Grafana
- Set up backup solutions
- Implement GitOps with ArgoCD
- Add additional worker nodes for scaling
- Configure ingress controllers and certificates
