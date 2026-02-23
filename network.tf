# Private Network
resource "hcloud_network" "rke2_network" {
  name     = "${var.cluster_name}-network"
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "rke2_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.rke2_network.id
  network_zone = var.network_zone
  ip_range     = var.subnet_cidr
}

# Firewall for Control Plane nodes
resource "hcloud_firewall" "control_plane" {
  name = "${var.cluster_name}-control-plane-fw"

  # SSH access
  dynamic "rule" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      direction  = "in"
      port       = "22"
      protocol   = "tcp"
      source_ips = var.ssh_allowed_ips
    }
  }

  # Kubernetes API server (6443) - All RKE2 nodes + external access
  rule {
    direction = "in"
    port      = "6443"
    protocol  = "tcp"
    source_ips = [
      var.network_cidr,
      "0.0.0.0/0" # Allow external access via load balancer
    ]
  }

  # RKE2 supervisor API (9345) - All RKE2 nodes to server nodes
  rule {
    direction  = "in"
    port       = "9345"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # kubelet metrics (10250) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "10250"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # etcd client port (2379) - Server nodes to server nodes
  rule {
    direction  = "in"
    port       = "2379"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # etcd peer port (2380) - Server nodes to server nodes
  rule {
    direction  = "in"
    port       = "2380"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # etcd metrics port (2381) - Server nodes to server nodes
  rule {
    direction  = "in"
    port       = "2381"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # NodePort services (30000-32767) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction = "in"
    port      = "30000-32767"
    protocol  = "tcp"
    source_ips = [
      var.network_cidr,
      "0.0.0.0/0" # Allow external access for NodePort services
    ]
  }

  # Canal CNI with VXLAN (8472) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "8472"
    protocol   = "udp"
    source_ips = [var.network_cidr]
  }

  # Canal CNI health checks (9099) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "9099"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # Canal CNI with WireGuard IPv4 (51820) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "51820"
    protocol   = "udp"
    source_ips = [var.network_cidr]
  }

  # Canal CNI with WireGuard IPv6/dual-stack (51821) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "51821"
    protocol   = "udp"
    source_ips = [var.network_cidr]
  }

  # Allow ICMP for internal network
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = [var.network_cidr]
  }

  # Admission controller webhooks (8443, 9443) - Internal cluster traffic
  rule {
    direction  = "in"
    port       = "8443"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  rule {
    direction  = "in"
    port       = "9443"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # Allow all outgoing TCP requests
  rule {
    direction       = "out"
    port            = "any"
    protocol        = "tcp"
    destination_ips = ["0.0.0.0/0"]
  }

  # Allow all outgoing UDP requests for CNI and other services
  rule {
    direction       = "out"
    port            = "any"
    protocol        = "udp"
    destination_ips = ["0.0.0.0/0"]
  }
}

# Firewall for Worker nodes
resource "hcloud_firewall" "worker" {
  name = "${var.cluster_name}-worker-fw"

  # SSH access
  dynamic "rule" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      direction  = "in"
      port       = "22"
      protocol   = "tcp"
      source_ips = var.ssh_allowed_ips
    }
  }

  # kubelet metrics (10250) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "10250"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # NodePort services (30000-32767) - All RKE2 nodes + external access
  rule {
    direction = "in"
    port      = "30000-32767"
    protocol  = "tcp"
    source_ips = [
      var.network_cidr,
      "0.0.0.0/0" # Allow external access for NodePort services
    ]
  }

  # Canal CNI with VXLAN (8472) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "8472"
    protocol   = "udp"
    source_ips = [var.network_cidr]
  }

  # Canal CNI health checks (9099) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "9099"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # Canal CNI with WireGuard IPv4 (51820) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "51820"
    protocol   = "udp"
    source_ips = [var.network_cidr]
  }

  # Canal CNI with WireGuard IPv6/dual-stack (51821) - All RKE2 nodes to all RKE2 nodes
  rule {
    direction  = "in"
    port       = "51821"
    protocol   = "udp"
    source_ips = [var.network_cidr]
  }

  # Allow ICMP for internal network
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = [var.network_cidr]
  }

  # HTTP for ingress-nginx (80) - External access
  rule {
    direction  = "in"
    port       = "80"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0"]
  }

  # HTTPS for ingress-nginx (443) - External access  
  rule {
    direction  = "in"
    port       = "443"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0"]
  }

  # Admission controller webhooks (8443, 9443) - Internal cluster traffic
  rule {
    direction  = "in"
    port       = "8443"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  rule {
    direction  = "in"
    port       = "9443"
    protocol   = "tcp"
    source_ips = [var.network_cidr]
  }

  # Allow all outgoing TCP requests
  rule {
    direction       = "out"
    port            = "any"
    protocol        = "tcp"
    destination_ips = ["0.0.0.0/0"]
  }

  # Allow all outgoing UDP requests for CNI and other services
  rule {
    direction       = "out"
    port            = "any"
    protocol        = "udp"
    destination_ips = ["0.0.0.0/0"]
  }
}
