terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.52.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.2.0"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}
