# Required variables for the SSH-disabled example
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "rke2_token" {
  description = "RKE2 cluster token"
  type        = string
  sensitive   = true
}
