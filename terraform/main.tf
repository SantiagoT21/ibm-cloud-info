# Data source to get the resource group
data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Create Code Engine project
resource "ibm_code_engine_project" "project" {
  name              = var.project_name
  resource_group_id = data.ibm_resource_group.resource_group.id
  
  tags = var.tags

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}