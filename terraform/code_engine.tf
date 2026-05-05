# Code Engine Application
resource "ibm_code_engine_app" "app" {
  project_id = ibm_code_engine_project.project.project_id
  name       = var.app_name
  
  image_reference = var.container_image
  image_port      = var.container_port
  
  # Scaling configuration
  scale_min_instances      = var.min_scale
  scale_max_instances      = var.max_scale
  scale_cpu_limit          = var.cpu
  scale_memory_limit       = var.memory
  scale_request_timeout    = var.request_timeout
  
  # Concurrency and scaling behavior
  scale_concurrency        = 100
  scale_concurrency_target = 80
  
  # Make the application publicly accessible
  run_as_user = 1000
  
  # Environment variables (optional)
  run_env_variables {
    type  = "literal"
    name  = "APP_NAME"
    value = var.app_name
  }
  
  run_env_variables {
    type  = "literal"
    name  = "ENVIRONMENT"
    value = "production"
  }
  
  run_env_variables {
    type  = "literal"
    name  = "PORT"
    value = tostring(var.container_port)
  }

  depends_on = [
    ibm_code_engine_project.project
  ]

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
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