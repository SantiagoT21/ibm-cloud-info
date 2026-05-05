# Project outputs
output "project_id" {
  description = "ID of the Code Engine project"
  value       = ibm_code_engine_project.project.project_id
}

output "project_name" {
  description = "Name of the Code Engine project"
  value       = ibm_code_engine_project.project.name
}

output "project_region" {
  description = "Region where the project is deployed"
  value       = var.region
}

# Application outputs
output "application_name" {
  description = "Name of the Code Engine application"
  value       = ibm_code_engine_app.app.name
}

output "application_url" {
  description = "Public URL of the deployed application"
  value       = "https://${ibm_code_engine_app.app.endpoint}"
}

output "application_endpoint" {
  description = "Endpoint of the Code Engine application"
  value       = ibm_code_engine_app.app.endpoint
}

output "application_status" {
  description = "Current status of the application"
  value       = ibm_code_engine_app.app.status
}

# Resource group output
output "resource_group_id" {
  description = "ID of the resource group"
  value       = data.ibm_resource_group.resource_group.id
}

# Scaling configuration outputs
output "scaling_config" {
  description = "Scaling configuration of the application"
  value = {
    min_instances = ibm_code_engine_app.app.scale_min_instances
    max_instances = ibm_code_engine_app.app.scale_max_instances
    cpu_limit     = ibm_code_engine_app.app.scale_cpu_limit
    memory_limit  = ibm_code_engine_app.app.scale_memory_limit
  }
}

# Deployment summary
output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    project_name      = ibm_code_engine_project.project.name
    application_name  = ibm_code_engine_app.app.name
    application_url   = "https://${ibm_code_engine_app.app.endpoint}"
    region           = var.region
    container_image  = var.container_image
    status           = ibm_code_engine_app.app.status
  }
}