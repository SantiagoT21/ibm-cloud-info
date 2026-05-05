# Workspace outputs
output "workspace_id" {
  description = "ID of the PowerVS workspace"
  value       = ibm_pi_workspace.workspace.id
}

output "workspace_name" {
  description = "Name of the PowerVS workspace"
  value       = ibm_pi_workspace.workspace.pi_name
}

output "workspace_location" {
  description = "Location of the PowerVS workspace"
  value       = ibm_pi_workspace.workspace.pi_datacenter
}

# Network outputs
output "private_network_id" {
  description = "ID of the private network"
  value       = ibm_pi_network.private_network.network_id
}

output "private_network_cidr" {
  description = "CIDR of the private network"
  value       = ibm_pi_network.private_network.pi_cidr
}

# Instance outputs
output "instance_id" {
  description = "ID of the PowerVS instance"
  value       = ibm_pi_instance.instance.instance_id
}

output "instance_name" {
  description = "Name of the PowerVS instance"
  value       = ibm_pi_instance.instance.pi_instance_name
}

output "instance_status" {
  description = "Status of the PowerVS instance"
  value       = ibm_pi_instance.instance.status
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = try(ibm_pi_instance.instance.pi_network[0].ip_address, "Not available yet")
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = try(ibm_pi_instance.instance.pi_network[1].external_ip, "Not available yet")
}

output "ssh_key_name" {
  description = "Name of the SSH key"
  value       = ibm_pi_key.ssh_key.pi_key_name
}

# Application URL
output "application_url" {
  description = "URL to access the application"
  value       = try("http://${ibm_pi_instance.instance.pi_network[1].external_ip}", "Public IP not available yet - check instance_public_ip output")
}

# SSH connection command
output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = try("ssh root@${ibm_pi_instance.instance.pi_network[1].external_ip}", "Public IP not available yet")
}

# Summary output
output "deployment_summary" {
  description = "Summary of the PowerVS deployment"
  value = {
    workspace_name   = ibm_pi_workspace.workspace.pi_name
    workspace_zone   = ibm_pi_workspace.workspace.pi_datacenter
    instance_name    = ibm_pi_instance.instance.pi_instance_name
    instance_type    = "${var.instance_processors} cores, ${var.instance_memory}GB RAM"
    storage_size     = "${var.instance_storage_size}GB"
    os_image         = var.instance_image_name
    private_ip       = try(ibm_pi_instance.instance.pi_network[0].ip_address, "Pending")
    public_ip        = try(ibm_pi_instance.instance.pi_network[1].external_ip, "Pending")
    application_url  = try("http://${ibm_pi_instance.instance.pi_network[1].external_ip}", "Pending")
  }
}