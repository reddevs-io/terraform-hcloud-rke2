# Basic Example

Creates a private network, an API load balancer, `1 + nb_cp_additional_servers`
control plane nodes and `nb_worker_servers` workers, all bootstrapped by
cloud-init. The RKE2 token is generated with the `random` provider.

Control planes are derived into the `control_planes` map in `main.tf`: the key
`primary` initialises the cluster (`first = true`), the others join through the
load balancer. Private IPs start at `.10` of `subnet_cidr`.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in the values
tofu init
tofu plan
tofu apply
```

Retrieve the kubeconfig with the command printed by the `kubeconfig_command`
output.

## Variables

See `variables.tf`. Per-node overrides (server type, location, bootstrap mode)
are documented in the root module README under `control_planes`.
