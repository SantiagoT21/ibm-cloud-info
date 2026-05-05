# Data source to get the resource group
data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Data source to get available images in the PowerVS workspace
# This will be used after the workspace is created
data "ibm_pi_images" "available_images" {
  depends_on       = [ibm_pi_workspace.workspace]
  pi_cloud_instance_id = ibm_pi_workspace.workspace.id
}

# Data source to get specific image by name
data "ibm_pi_image" "os_image" {
  depends_on       = [ibm_pi_workspace.workspace]
  pi_cloud_instance_id = ibm_pi_workspace.workspace.id
  pi_image_name    = var.instance_image_name
}

# Data source to get available system pools
data "ibm_pi_system_pools" "system_pools" {
  depends_on       = [ibm_pi_workspace.workspace]
  pi_cloud_instance_id = ibm_pi_workspace.workspace.id
}