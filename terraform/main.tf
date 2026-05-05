# Data source to get the resource group
data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Use existing Code Engine project or create if it doesn't exist
data "ibm_code_engine_project" "project" {
  name = var.project_name
}