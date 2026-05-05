# Create PowerVS Workspace
resource "ibm_pi_workspace" "workspace" {
  pi_name              = var.workspace_name
  pi_datacenter        = var.powervs_zone
  pi_resource_group_id = data.ibm_resource_group.resource_group.id
  
  pi_plan = "public"
  
  tags = var.tags

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# Wait for workspace to be fully ready
resource "time_sleep" "wait_for_workspace" {
  depends_on = [ibm_pi_workspace.workspace]
  
  create_duration = "60s"
}