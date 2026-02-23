# Load Balancer for Kubernetes API
resource "hcloud_load_balancer" "api_server" {
  name               = "${var.cluster_name}-api-lb"
  load_balancer_type = "lb11"
  location           = var.control_plane_location
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

# Update Load Balancer targets to include all control plane nodes
resource "hcloud_load_balancer_target" "api_server_first" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.api_server.id
  server_id        = hcloud_server.control_plane_first.id
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_service.api_server,
    hcloud_server_network.control_plane_first_network
  ]
}

resource "hcloud_load_balancer_target" "api_server_additional" {
  count            = var.nb_cp_additional_servers
  type             = "server"
  load_balancer_id = hcloud_load_balancer.api_server.id
  server_id        = hcloud_server.control_plane_additional[count.index].id
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_service.api_server,
    hcloud_server_network.control_plane_additional_network
  ]
}

