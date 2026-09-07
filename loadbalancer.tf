locals {
  api_lb_location = coalesce(var.api_lb_location, var.control_plane_location)
}

# Load Balancer for Kubernetes API
resource "hcloud_load_balancer" "api_server" {
  name               = "${var.cluster_name}-api-lb"
  load_balancer_type = "lb11"
  location           = local.api_lb_location
}

resource "hcloud_load_balancer_network" "api_server" {
  load_balancer_id = hcloud_load_balancer.api_server.id
  subnet_id        = hcloud_network_subnet.rke2_subnet.id
}

resource "hcloud_load_balancer_service" "api_server" {
  load_balancer_id = hcloud_load_balancer.api_server.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443

  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

resource "hcloud_load_balancer_service" "rke_supervisor_api" {
  load_balancer_id = hcloud_load_balancer.api_server.id
  protocol         = "tcp"
  listen_port      = 9345
  destination_port = 9345

  health_check {
    protocol = "tcp"
    port     = 9345
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

# Every control plane node is a load balancer target. Targets that are not yet
# running RKE2 simply fail the health check and receive no traffic.
resource "hcloud_load_balancer_target" "control_plane" {
  for_each = local.control_planes

  type             = "server"
  load_balancer_id = hcloud_load_balancer.api_server.id
  server_id        = hcloud_server.control_plane[each.key].id
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_service.api_server,
    hcloud_load_balancer_service.rke_supervisor_api,
    hcloud_server_network.control_plane
  ]
}
