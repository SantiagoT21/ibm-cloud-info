# Create private network for PowerVS
resource "ibm_pi_network" "private_network" {
  depends_on = [ibm_pi_workspace.workspace]
  
  pi_cloud_instance_id = ibm_pi_workspace.workspace.id
  pi_network_name      = var.network_name
  pi_network_type      = "vlan"
  pi_cidr              = var.network_cidr
  pi_dns               = var.network_dns
  
  # Gateway will be automatically assigned as the first IP in the CIDR
  pi_gateway = cidrhost(var.network_cidr, 1)

  timeouts {
    create = "15m"
    delete = "15m"
  }
}