# IBM Cloud Authentication
variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key for authentication"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region (for VPC and other services)"
  type        = string
  default     = "us-south"
  
  validation {
    condition     = contains(["us-south", "us-east", "eu-de", "eu-gb", "jp-tok", "au-syd"], var.region)
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "powervs_zone" {
  description = "PowerVS zone where the workspace will be created"
  type        = string
  default     = "dal12"
  
  validation {
    condition     = contains(["dal12", "dal13", "lon06", "syd04", "syd05", "tok04", "wdc06", "wdc07", "sao01", "mon01"], var.powervs_zone)
    error_message = "PowerVS zone must be a valid zone."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "Default"
}

# PowerVS Workspace Configuration
variable "workspace_name" {
  description = "Name of the PowerVS workspace"
  type        = string
  default     = "ibm-cloud-info-workspace"
  
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.workspace_name))
    error_message = "Workspace name must consist of lowercase alphanumeric characters or '-', and must start and end with an alphanumeric character."
  }
}

# Network Configuration
variable "network_name" {
  description = "Name of the private network"
  type        = string
  default     = "ibm-cloud-info-network"
}

variable "network_cidr" {
  description = "CIDR block for the private network"
  type        = string
  default     = "192.168.0.0/24"
  
  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "Network CIDR must be a valid IPv4 CIDR block."
  }
}

variable "network_dns" {
  description = "DNS servers for the network"
  type        = list(string)
  default     = ["9.9.9.9", "1.1.1.1"]
}

# Instance Configuration
variable "instance_name" {
  description = "Name of the PowerVS instance (LPAR)"
  type        = string
  default     = "ibm-cloud-info-lpar"
  
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.instance_name))
    error_message = "Instance name must consist of lowercase alphanumeric characters or '-', and must start and end with an alphanumeric character."
  }
}

variable "instance_image_name" {
  description = "Name of the OS image to use (e.g., 'Rocky-Linux-9', 'RHEL9-SP2', 'CentOS-Stream-9')"
  type        = string
  default     = "Rocky-Linux-9"
}

variable "instance_processors" {
  description = "Number of processors (cores) for the instance"
  type        = number
  default     = 0.25
  
  validation {
    condition     = var.instance_processors >= 0.25 && var.instance_processors <= 32
    error_message = "Processors must be between 0.25 and 32."
  }
}

variable "instance_memory" {
  description = "Memory in GB for the instance"
  type        = number
  default     = 2
  
  validation {
    condition     = var.instance_memory >= 2 && var.instance_memory <= 934
    error_message = "Memory must be between 2 and 934 GB."
  }
}

variable "instance_proc_type" {
  description = "Processor type: shared or dedicated"
  type        = string
  default     = "shared"
  
  validation {
    condition     = contains(["shared", "dedicated", "capped"], var.instance_proc_type)
    error_message = "Processor type must be 'shared', 'dedicated', or 'capped'."
  }
}

variable "instance_sys_type" {
  description = "System type for the instance"
  type        = string
  default     = "s922"
  
  validation {
    condition     = contains(["s922", "e980", "e1080"], var.instance_sys_type)
    error_message = "System type must be 's922', 'e980', or 'e1080'."
  }
}

variable "instance_storage_tier" {
  description = "Storage tier for the instance"
  type        = string
  default     = "tier3"
  
  validation {
    condition     = contains(["tier0", "tier1", "tier3", "tier5k"], var.instance_storage_tier)
    error_message = "Storage tier must be 'tier0', 'tier1', 'tier3', or 'tier5k'."
  }
}

variable "instance_storage_size" {
  description = "Storage size in GB for the instance"
  type        = number
  default     = 20
  
  validation {
    condition     = var.instance_storage_size >= 20 && var.instance_storage_size <= 2000
    error_message = "Storage size must be between 20 and 2000 GB."
  }
}

# SSH Configuration
variable "ssh_key_name" {
  description = "Name for the SSH key in PowerVS"
  type        = string
  default     = "ibm-cloud-info-ssh-key"
}

variable "ssh_public_key" {
  description = "SSH public key content for accessing the instance"
  type        = string
  sensitive   = true
}

# Application Configuration
variable "app_port" {
  description = "Port where the application will listen"
  type        = number
  default     = 80
  
  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "Application port must be between 1 and 65535."
  }
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["terraform", "powervs", "ibm-cloud-info"]
}