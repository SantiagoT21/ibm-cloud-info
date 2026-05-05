# Code Engine Application
resource "ibm_code_engine_app" "app" {
  project_id = ibm_code_engine_project.project.project_id
  name       = var.app_name
  
  image_reference = var.container_image
  image_port      = var.container_port
  
  # Minimal scaling configuration
  scale_cpu_limit    = var.cpu
  scale_memory_limit = var.memory

  depends_on = [
    ibm_code_engine_project.project
  ]
}

# Output the application URL
output "app_url" {
  description = "URL of the deployed Code Engine application"
  value       = ibm_code_engine_app.app.endpoint
}

output "app_status" {
  description = "Status of the Code Engine application"
  value       = ibm_code_engine_app.app.status
}