# Create SSH key for instance access
resource "ibm_pi_key" "ssh_key" {
  depends_on = [time_sleep.wait_for_workspace]
  
  pi_cloud_instance_id = ibm_pi_workspace.workspace.id
  pi_key_name          = var.ssh_key_name
  pi_ssh_key           = var.ssh_public_key

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Note: PowerVS doesn't have security groups like VPC.
# Network security is managed at the network level and through
# the operating system's firewall (firewalld in Rocky Linux).
# The setup script will configure firewalld to allow:
# - SSH (port 22)
# - HTTP (port 80)
# - HTTPS (port 443)