terraform {
  required_version = ">= 1.0"
  
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.63.0"
    }
  }

  # Optional: Configure backend for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "ibm-cloud-info/terraform.tfstate"
  #   region = "us-south"
  #   endpoint = "s3.us-south.cloud-object-storage.appdomain.cloud"
  # }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}