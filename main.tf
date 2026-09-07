terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      # 1.67+ is required: Hetzner removed the `datacenter` attribute from the
      # API on 2026-07-01 and older providers read `location` back as null,
      # which forces a replacement of every server on the next plan.
      version = "~> 1.68"
    }
  }

  required_version = ">= 1.8.0"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}
