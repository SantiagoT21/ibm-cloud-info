# Registry Secret for IBM Container Registry
resource "ibm_code_engine_secret" "registry_secret" {
  project_id = ibm_code_engine_project.project.id
  name       = "icr-secret"
  format     = "registry"

  data = {
    username = "iamapikey"
    password = var.ibmcloud_api_key
    server   = "icr.io"
  }

  lifecycle {
    # Prevent accidental deletion of the secret
    prevent_destroy = false
    # Ignore changes to password if managed externally
    ignore_changes = []
  }

  depends_on = [
    ibm_code_engine_project.project
  ]
}

# Code Engine Application
resource "ibm_code_engine_app" "app" {
  project_id = ibm_code_engine_project.project.id
  name       = var.app_name
  
  image_reference = var.container_image
  image_port      = var.container_port
  image_secret    = ibm_code_engine_secret.registry_secret.name
  
  # Scaling configuration
  scale_cpu_limit      = var.cpu
  scale_memory_limit   = var.memory
  scale_min_instances  = var.min_scale
  scale_max_instances  = var.max_scale
  scale_request_timeout = var.request_timeout
  
  # Increase deployment timeout to 20 minutes
  timeouts {
    create = "20m"
    update = "20m"
  }

  lifecycle {
    # Create new version before destroying old one (zero-downtime updates)
    create_before_destroy = true
    
    # Ignore changes to certain attributes that might cause unnecessary updates
    ignore_changes = [
      # Uncomment if you want to ignore status changes
      # status,
    ]
  }

  depends_on = [
    ibm_code_engine_project.project,
    ibm_code_engine_secret.registry_secret
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