# Code Engine Application
resource "ibm_code_engine_app" "app" {
  project_id = ibm_code_engine_project.project.project_id
  name       = var.app_name
  
  image_reference = var.container_image
  image_port      = var.container_port
  
  # Scaling configuration
  scale_min_instances   = var.min_scale
  scale_max_instances   = var.max_scale
  scale_cpu_limit       = var.cpu
  scale_memory_limit    = var.memory
  scale_request_timeout = var.request_timeout
  
  # Concurrency
  scale_concurrency        = 100
  scale_concurrency_target = 80

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