# SSH Disabled Example

This example demonstrates how to deploy an RKE2 cluster with SSH access disabled in the firewall rules.

## Configuration

The key difference from the basic example is:

```hcl
# SSH configuration - DISABLED
enable_ssh_access = false
ssh_allowed_ips   = [] # Not used when SSH is disabled
```

When `enable_ssh_access` is set to `false`, the SSH rules (port 22) will be completely omitted from both the control plane and worker node firewalls.

## Security Considerations

- **No SSH Access**: With SSH disabled, you won't be able to SSH directly to the nodes
- **Alternative Access**: Consider using:
  - Hetzner Cloud Console for emergency access
  - Jump hosts or bastion servers if needed
  - Kubernetes exec for application troubleshooting

## Usage

1. Create a `terraform.tfvars` file with the required variables:
   ```hcl
   hcloud_token = "your-hetzner-cloud-api-token"
   rke2_token   = "your-rke2-cluster-token"
   ```
2. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Variables

See `variables.tf` for all available configuration options.
