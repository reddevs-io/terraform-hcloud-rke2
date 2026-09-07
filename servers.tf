# SSH Key
resource "hcloud_ssh_key" "rke2_key" {
  name       = "${var.cluster_name}-ssh-key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_placement_group" "cp_placement_group" {
  name = "${var.cluster_name}-cp-placement-group"
  type = "spread"
}

resource "hcloud_placement_group" "worker_placement_group" {
  name = "${var.cluster_name}-worker-placement-group"
  type = "spread"
}

locals {
  api_server_domain = var.api_server_domain != null ? var.api_server_domain : ""
  rke2_version      = var.rke2_version != null ? var.rke2_version : ""

  # Node that initialises the cluster. Falls back to the first key in sorted
  # order when no entry sets `first = true` (only matters for outputs).
  first_control_plane_key = try(
    one([for k, v in var.control_planes : k if v.first]),
    sort(keys(var.control_planes))[0],
  )

  control_planes = {
    for k, v in var.control_planes : k => merge(v, {
      name        = "${var.cluster_name}-control-${k}"
      server_type = coalesce(v.server_type, var.control_plane_server_type)
      location    = coalesce(v.location, var.control_plane_location)
    })
  }
}

# Control plane servers. Nodes with bootstrap = "cloud-init" install and start
# RKE2 from user data (the `first` node initialises the cluster, the others join
# through the load balancer and retry until it answers). Nodes with
# bootstrap = "external" only receive base packages and are joined by an
# external tool.
resource "hcloud_server" "control_plane" {
  for_each = local.control_planes

  name               = each.value.name
  image              = var.server_image
  server_type        = each.value.server_type
  location           = each.value.location
  ssh_keys           = [hcloud_ssh_key.rke2_key.id]
  firewall_ids       = [hcloud_firewall.control_plane.id]
  placement_group_id = hcloud_placement_group.cp_placement_group.id

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  user_data = each.value.bootstrap == "external" ? templatefile("${path.module}/cloud-init/minimal.yml", {
    node_name = each.value.name
    }) : templatefile("${path.module}/cloud-init/control-plane.yml", {
    node_name            = each.value.name
    is_first_node        = each.value.first
    cluster_token        = var.rke2_token
    lb_public_ip         = hcloud_load_balancer.api_server.ipv4
    lb_private_ip        = hcloud_load_balancer_network.api_server.ip
    api_domain           = local.api_server_domain
    node_private_ip      = each.value.private_ip
    datastore_endpoint   = var.datastore_endpoint
    install_rke2_channel = var.rke2_channel
    install_rke2_version = local.rke2_version
  })

  labels = merge(each.value.labels, {
    node-type = "control-plane"
  })

  lifecycle {
    # user_data and ssh_keys are only consumed at creation (and the API never
    # returns ssh_keys, so imported servers have none). Ignoring them means a change to
    # the cloud-init templates, the RKE2 version pin or the datastore endpoint
    # never replaces a running node; recreate a node deliberately with
    # `tofu apply -replace` when that is intended.
    ignore_changes = [user_data, ssh_keys]
  }

  depends_on = [
    hcloud_network_subnet.rke2_subnet,
    hcloud_load_balancer.api_server
  ]
}

# Attach control plane servers to the private network
resource "hcloud_server_network" "control_plane" {
  for_each = local.control_planes

  server_id = hcloud_server.control_plane[each.key].id
  subnet_id = hcloud_network_subnet.rke2_subnet.id
  ip        = each.value.private_ip

  lifecycle {
    # subnet_id is a creation-time selector; the API only reports the network,
    # so imported attachments carry no subnet_id. The attachment is identified
    # by server_id and ip, which are still compared.
    ignore_changes = [subnet_id]
  }
}

# Worker Servers (depend on all control plane nodes)
resource "hcloud_server" "workers" {
  count              = var.nb_worker_servers
  name               = "${var.cluster_name}-worker-${var.cluster_server_names_worker[count.index]}"
  image              = var.server_image
  server_type        = var.worker_server_type
  location           = var.worker_location
  ssh_keys           = [hcloud_ssh_key.rke2_key.id]
  firewall_ids       = [hcloud_firewall.worker.id]
  placement_group_id = hcloud_placement_group.worker_placement_group.id

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/cloud-init/worker.yml", {
    node_name            = "${var.cluster_name}-worker-${var.cluster_server_names_worker[count.index]}"
    cluster_token        = var.rke2_token
    lb_private_ip        = hcloud_load_balancer_network.api_server.ip
    api_domain           = local.api_server_domain
    node_private_ip      = var.private_ips_workers[count.index]
    install_rke2_channel = var.rke2_channel
    install_rke2_version = local.rke2_version
  })

  depends_on = [
    hcloud_network_subnet.rke2_subnet,
    hcloud_server_network.control_plane
  ]

  labels = {
    node-type = "worker"
  }

  lifecycle {
    # user_data and ssh_keys are only consumed at creation (and the API never
    # returns ssh_keys, so imported servers have none). Ignoring them means a change to
    # the cloud-init templates, the RKE2 version pin or the datastore endpoint
    # never replaces a running node; recreate a node deliberately with
    # `tofu apply -replace` when that is intended.
    ignore_changes = [user_data, ssh_keys]
  }
}

# Attach workers to private network
resource "hcloud_server_network" "worker_network" {
  count     = var.nb_worker_servers
  server_id = hcloud_server.workers[count.index].id
  subnet_id = hcloud_network_subnet.rke2_subnet.id
  ip        = var.private_ips_workers[count.index]

  lifecycle {
    # subnet_id is a creation-time selector; the API only reports the network,
    # so imported attachments carry no subnet_id. The attachment is identified
    # by server_id and ip, which are still compared.
    ignore_changes = [subnet_id]
  }
}
