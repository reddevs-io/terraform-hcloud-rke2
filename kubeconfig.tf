# kubeconfig.tf - Kubeconfig Export Functionality
#
# This file handles retrieving the admin kubeconfig from the first RKE2 control plane node
# after the cluster is installed. It uses SSH to connect to the node and copy the kubeconfig.
#
# IMPORTANT: This functionality requires enable_ssh_access = true. When SSH access is disabled
# (the default), these resources are not created and the kubeconfig output will be null.
# Users must manually retrieve the kubeconfig using the command from kubeconfig_command output.

# Random ID to make the temp SSH key filename unique per deployment
resource "random_id" "ssh_key_suffix" {
  count = var.enable_ssh_access ? 1 : 0

  byte_length = 4
}

# Write SSH private key to a temporary file for use with scp
# This avoids leaking the key through shell interpolation/command line
# Uses the user-provided private key path
resource "local_sensitive_file" "ssh_key_for_kubeconfig" {
  count = var.enable_ssh_access && var.ssh_private_key_path != null ? 1 : 0

  content         = var.ssh_private_key_path != null ? file(var.ssh_private_key_path) : ""
  filename        = "${path.module}/.tmp_ssh_key_${random_id.ssh_key_suffix[0].hex}"
  file_permission = "0600"
}

# Capture the host key of the first control plane server for strict host verification
# This runs after the server is provisioned and stores the host key for secure SSH
resource "null_resource" "capture_host_key" {
  count = var.enable_ssh_access ? 1 : 0

  depends_on = [
    hcloud_server.control_plane_first,
    hcloud_server_network.control_plane_first_network
  ]

  # Trigger renewal when server IP changes
  triggers = {
    server_ip = hcloud_server.control_plane_first.ipv4_address
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Capture host key with timeout (server may not be immediately ready for SSH)
      for i in $(seq 1 30); do
        if ssh-keyscan -T 5 -t ecdsa,ed25519,rsa ${hcloud_server.control_plane_first.ipv4_address} > "${path.module}/.known_hosts_${random_id.ssh_key_suffix[0].hex}" 2>/dev/null; then
          echo "Host key captured successfully"
          exit 0
        fi
        echo "Waiting for SSH to be available... (attempt $i/30)"
        sleep 10
      done
      echo "Failed to capture host key after 5 minutes"
      exit 1
    EOT
  }
}

# Null resource to wait for RKE2 to be ready and copy kubeconfig locally
resource "null_resource" "kubeconfig_export" {
  count = var.enable_ssh_access && var.ssh_private_key_path != null ? 1 : 0

  # Depends on the first control plane server being fully provisioned
  # including network attachment and host key capture
  depends_on = [
    hcloud_server.control_plane_first,
    hcloud_server_network.control_plane_first_network,
    null_resource.capture_host_key[0],
    local_sensitive_file.ssh_key_for_kubeconfig[0]
  ]

  # Trigger renewal when server IP or SSH key changes
  triggers = {
    server_ip      = hcloud_server.control_plane_first.ipv4_address
    ssh_key_id     = local_sensitive_file.ssh_key_for_kubeconfig[0].id
    kubeconfig_dir = dirname(var.kubeconfig_path)
  }

  # Connection configuration for SSH access to the first control plane node
  connection {
    type        = "ssh"
    user        = "root"
    host        = hcloud_server.control_plane_first.ipv4_address
    private_key = var.ssh_private_key_path != null ? file(var.ssh_private_key_path) : null
    timeout     = "10m"
  }

  # Remote provisioner: Wait for RKE2 to be fully ready
  # - Wait for kubeconfig file to exist
  # - Wait for rke2-server service to be active
  # - Timeout after 10 minutes, polling every 5 seconds
  provisioner "remote-exec" {
    inline = [
      "until [ -f /etc/rancher/rke2/rke2.yaml ] && systemctl is-active --quiet rke2-server; do",
      "  echo 'Waiting for RKE2 to be ready...'",
      "  sleep 5",
      "done",
      "echo 'RKE2 is ready - kubeconfig file exists and service is active'"
    ]
  }

  # Local provisioner: Copy kubeconfig from remote node to local machine
  # Uses the SSH key file written by local_sensitive_file (not shell interpolation)
  # Uses strict host key verification with the captured host key
  provisioner "local-exec" {
    command = <<-EOT
      # Ensure the target directory exists
      KUBECONFIG_DIR=$(dirname "${var.kubeconfig_path}")
      mkdir -p "$KUBECONFIG_DIR"
      
      # Copy kubeconfig from first control plane node with strict host verification
      scp -o StrictHostKeyChecking=yes \
          -o UserKnownHostsFile="${path.module}/.known_hosts_${random_id.ssh_key_suffix[0].hex}" \
          -i "${local_sensitive_file.ssh_key_for_kubeconfig[0].filename}" \
          "root@${hcloud_server.control_plane_first.ipv4_address}:/etc/rancher/rke2/rke2.yaml" \
          "${var.kubeconfig_path}"
      
      echo "Kubeconfig copied to ${var.kubeconfig_path}"
    EOT
  }
}

# Cleanup resource to remove temporary files on destroy
# Uses triggers to store file paths for access during destroy phase
resource "null_resource" "cleanup_temp_files" {
  count = var.enable_ssh_access && var.ssh_private_key_path != null ? 1 : 0

  depends_on = [
    null_resource.kubeconfig_export[0]
  ]

  # Store paths in triggers so they're accessible via self.triggers during destroy
  triggers = {
    ssh_key_file = "${path.module}/.tmp_ssh_key_${random_id.ssh_key_suffix[0].hex}"
    known_hosts  = "${path.module}/.known_hosts_${random_id.ssh_key_suffix[0].hex}"
    kubeconfig   = var.kubeconfig_path
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f "${self.triggers.ssh_key_file}"
      rm -f "${self.triggers.known_hosts}"
      rm -f "${self.triggers.kubeconfig}"
    EOT
  }
}

# Read the kubeconfig file if it exists
# Using try() to avoid errors during plan on fresh deployments
#
# IMPORTANT LIMITATION: This local reads the kubeconfig file at plan time.
# If the file exists from a previous deployment but the cluster was recreated,
# the output may contain stale content until the next terraform apply completes.
# For the most up-to-date kubeconfig, run `terraform apply` twice or use the
# kubeconfig_command output to manually retrieve it after cluster changes.
locals {
  kubeconfig_content = var.enable_ssh_access && var.ssh_private_key_path != null ? try(
    sensitive(file(var.kubeconfig_path)),
    null
  ) : null
}
