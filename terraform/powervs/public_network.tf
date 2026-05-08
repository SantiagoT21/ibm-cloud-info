# Get public network information
# PowerVS provides a public network that can be attached to instances
data "ibm_pi_public_network" "public_network" {
  depends_on = [ibm_pi_workspace.workspace]
  
  pi_cloud_instance_id = ibm_pi_workspace.workspace.id
}

# Note: Public IP will be automatically assigned when the instance
# is attached to the public network. The IP will be available in
# the instance's network interfaces after creation.