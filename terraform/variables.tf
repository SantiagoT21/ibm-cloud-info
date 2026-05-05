variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key for authentication"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region where resources will be created"
  type        = string
  default     = "us-south"
  
  validation {
    condition     = contains(["us-south", "us-east", "eu-de", "eu-gb", "jp-tok", "au-syd"], var.region)
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "Default"
}

variable "project_name" {
  description = "Name of the Code Engine project"
  type        = string
  default     = "ibm-cloud-info"
  
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.project_name))
    error_message = "Project name must consist of lowercase alphanumeric characters or '-', and must start and end with an alphanumeric character."
  }
}

variable "app_name" {
  description = "Name of the Code Engine application"
  type        = string
  default     = "ibm-cloud-info-app"
  
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.app_name))
    error_message = "Application name must consist of lowercase alphanumeric characters or '-', and must start and end with an alphanumeric character."
  }
}

variable "container_image" {
  description = "Container image URL for the application"
  type        = string
  default     = "icr.io/namespace/ibm-cloud-info:latest"
}

variable "container_port" {
  description = "Port that the container listens on"
  type        = number
  default     = 8080
  
  validation {
    condition     = var.container_port > 0 && var.container_port < 65536
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "cpu" {
  description = "CPU allocation for each instance (in vCPU)"
  type        = string
  default     = "0.25"
  
  validation {
    condition     = contains(["0.125", "0.25", "0.5", "1", "2", "4", "6", "8"], var.cpu)
    error_message = "CPU must be one of: 0.125, 0.25, 0.5, 1, 2, 4, 6, 8."
  }
}

variable "memory" {
  description = "Memory allocation for each instance (in GB)"
  type        = string
  default     = "0.5G"
  
  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?[GM]$", var.memory))
    error_message = "Memory must be specified in GB (G) or MB (M), e.g., '0.5G' or '512M'."
  }
}

variable "min_scale" {
  description = "Minimum number of instances (0 for scale to zero)"
  type        = number
  default     = 0
  
  validation {
    condition     = var.min_scale >= 0 && var.min_scale <= 100
    error_message = "Min scale must be between 0 and 100."
  }
}

variable "max_scale" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
  
  validation {
    condition     = var.max_scale >= 1 && var.max_scale <= 100
    error_message = "Max scale must be between 1 and 100."
  }
}

variable "request_timeout" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300
  
  validation {
    condition     = var.request_timeout >= 1 && var.request_timeout <= 600
    error_message = "Request timeout must be between 1 and 600 seconds."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["terraform", "code-engine", "ibm-cloud-info"]
}