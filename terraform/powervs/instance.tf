# Create PowerVS Instance (LPAR)
resource "ibm_pi_instance" "instance" {
  depends_on = [
    time_sleep.wait_for_network,
    ibm_pi_key.ssh_key,
    data.ibm_pi_image.os_image
  ]
  
  pi_cloud_instance_id = ibm_pi_workspace.workspace.id
  pi_instance_name     = var.instance_name
  pi_image_id          = data.ibm_pi_image.os_image.id
  pi_key_pair_name     = ibm_pi_key.ssh_key.pi_key_name
  
  # Compute resources
  pi_processors        = var.instance_processors
  pi_memory            = var.instance_memory
  pi_proc_type         = var.instance_proc_type
  pi_sys_type          = var.instance_sys_type
  
  # Storage
  pi_storage_type      = var.instance_storage_tier
  pi_storage_pool_affinity = false
  
  # Network configuration - attach both private and public networks
  pi_network {
    network_id = ibm_pi_network.private_network.network_id
  }
  
  pi_network {
    network_id = data.ibm_pi_public_network.public_network.id
  }
  
  # User data for initial setup
  pi_user_data = base64encode(templatefile("${path.module}/../../scripts/powervs-setup.sh", {
    app_port = var.app_port
  }))
  
  # Health status check
  pi_health_status = "OK"
  
  timeouts {
    create = "45m"
    update = "30m"
    delete = "30m"
  }
}

# Wait for instance to be fully ready and user-data to execute
resource "time_sleep" "wait_for_instance" {
  depends_on = [ibm_pi_instance.instance]
  
  create_duration = "120s"
}