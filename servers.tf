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
}

# First Control Plane Server (cluster initializer)
resource "hcloud_server" "control_plane_first" {
  name               = "${var.cluster_name}-control-${var.cluster_server_names_cp[0]}"
  image              = var.server_image
  server_type        = var.control_plane_server_type
  location           = var.control_plane_location
  ssh_keys           = [hcloud_ssh_key.rke2_key.id]
  firewall_ids       = [hcloud_firewall.control_plane.id]
  placement_group_id = hcloud_placement_group.cp_placement_group.id

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

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

  labels = {
    node-type = "control-plane"
  }

  depends_on = [
    hcloud_network_subnet.rke2_subnet,
    hcloud_load_balancer.api_server
  ]
}

# Attach first control plane to private network
resource "hcloud_server_network" "control_plane_first_network" {
  server_id = hcloud_server.control_plane_first.id
  subnet_id = hcloud_network_subnet.rke2_subnet.id
  ip        = var.private_ips_cp[0]
}

# Additional Control Plane Servers (join existing cluster)
resource "hcloud_server" "control_plane_additional" {
  count              = var.nb_cp_additional_servers
  name               = "${var.cluster_name}-control-${var.cluster_server_names_cp[count.index + 1]}"
  image              = var.server_image
  server_type        = var.control_plane_server_type
  location           = var.control_plane_location
  ssh_keys           = [hcloud_ssh_key.rke2_key.id]
  firewall_ids       = [hcloud_firewall.control_plane.id]
  placement_group_id = hcloud_placement_group.cp_placement_group.id

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/cloud-init/control-plane.yml", {
    node_name          = "${var.cluster_name}-control-${var.cluster_server_names_cp[count.index + 1]}"
    is_first_node      = false
    cluster_token      = var.rke2_token
    lb_public_ip       = hcloud_load_balancer.api_server.ipv4
    lb_private_ip      = hcloud_load_balancer_network.api_server.ip
    api_domain         = local.api_server_domain
    node_private_ip    = var.private_ips_cp[count.index + 1]
    datastore_endpoint = var.datastore_endpoint
  })

  depends_on = [
    hcloud_network_subnet.rke2_subnet,
    hcloud_server_network.control_plane_first_network # Wait for first node to be ready
  ]

  labels = {
    node-type = "control-plane"
  }
}

# Attach additional control plane servers to private network
resource "hcloud_server_network" "control_plane_additional_network" {
  count     = var.nb_cp_additional_servers
  server_id = hcloud_server.control_plane_additional[count.index].id
  subnet_id = hcloud_network_subnet.rke2_subnet.id
  ip        = var.private_ips_cp[count.index + 1]
}

# Worker Servers (updated to depend on all control plane nodes)
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
    node_name       = "${var.cluster_name}-worker-${var.cluster_server_names_worker[count.index]}"
    cluster_token   = var.rke2_token
    lb_private_ip   = hcloud_load_balancer_network.api_server.ip
    api_domain      = local.api_server_domain
    node_private_ip = var.private_ips_workers[count.index]
  })

  depends_on = [
    hcloud_network_subnet.rke2_subnet,
    hcloud_server_network.control_plane_first_network,
    hcloud_server_network.control_plane_additional_network
  ]

  labels = {
    node-type = "worker"
  }
}

# Attach workers to private network
resource "hcloud_server_network" "worker_network" {
  count     = var.nb_worker_servers
  server_id = hcloud_server.workers[count.index].id
  subnet_id = hcloud_network_subnet.rke2_subnet.id
  ip        = var.private_ips_workers[count.index]
}
