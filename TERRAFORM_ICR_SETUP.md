# Terraform IBM Container Registry Setup Guide

## Overview

This guide explains how to configure Terraform to deploy IBM Cloud Code Engine applications using private images from IBM Container Registry (ICR).

## Configuration Changes

### What Was Added

1. **Registry Secret Resource** (`ibm_code_engine_secret.registry_secret`):
   - Creates a registry-type secret in Code Engine
   - Uses `iamapikey` as username
   - Uses your IBM Cloud API key as password
   - Configured for `icr.io` server

2. **Application Updates**:
   - Added `image_secret` parameter linking to the registry secret
   - Changed `project_id` to use `.id` instead of `.project_id` (recommended)
   - Added dependency on the registry secret

## Usage

### 1. Ensure Your Variables Are Set

Make sure your `terraform.tfvars` file includes:

```hcl
ibmcloud_api_key = "your-api-key-here"
container_image  = "icr.io/test_icr/ibm-cloud-info:latest"
```

### 2. Initialize Terraform (if not done)

```bash
cd terraform
terraform init
```

### 3. Plan Your Changes

```bash
terraform plan -out=tfplan
```

### 4. Apply the Configuration

```bash
terraform apply -auto-approve -input=false tfplan
```

## Importing Existing Resources

If you already have resources created and want to avoid recreating them, you can import them into Terraform state.

### Import Code Engine Project

```bash
terraform import ibm_code_engine_project.project <project_id>
```

To find your project ID:
```bash
ibmcloud ce project list
ibmcloud ce project get --name <project_name>
```

### Import Existing Registry Secret (if exists)

```bash
terraform import ibm_code_engine_secret.registry_secret <project_id>/<secret_name>
```

Example:
```bash
terraform import ibm_code_engine_secret.registry_secret abcd1234-5678-90ef-ghij-klmnopqrstuv/icr-secret
```

To list existing secrets:
```bash
ibmcloud ce project select --name <project_name>
ibmcloud ce secret list
```

### Import Existing Application (if exists)

```bash
terraform import ibm_code_engine_app.app <project_id>/<app_name>
```

Example:
```bash
terraform import ibm_code_engine_app.app abcd1234-5678-90ef-ghij-klmnopqrstuv/ibm-cloud-info-app
```

## Verification Steps

### 1. Verify Secret Creation

```bash
ibmcloud ce project select --name <project_name>
ibmcloud ce secret get --name icr-secret
```

### 2. Verify Application Configuration

```bash
ibmcloud ce app get --name <app_name>
```

Look for the `Image Secret` field in the output.

### 3. Test Application Access

```bash
curl https://<app_url>
```

The URL is available in Terraform outputs:
```bash
terraform output app_url
```

## Troubleshooting

### Error: "UNAUTHORIZED: Authorization required"

**Cause**: The registry secret is not properly configured or the API key doesn't have access to the registry.

**Solutions**:
1. Verify your API key has access to ICR:
   ```bash
   ibmcloud cr login
   ibmcloud cr images --restrict test_icr
   ```

2. Ensure the API key has the correct IAM permissions:
   - Viewer role on the Container Registry service
   - Reader role on the resource group

3. Verify the secret was created:
   ```bash
   ibmcloud ce secret get --name icr-secret
   ```

### Error: "Secret not found"

**Cause**: The application is trying to use a secret that doesn't exist yet.

**Solution**: Ensure the `depends_on` block includes the secret:
```hcl
depends_on = [
  ibm_code_engine_project.project,
  ibm_code_engine_secret.registry_secret
]
```

### Error: "Image pull failed"

**Cause**: The image doesn't exist or the path is incorrect.

**Solutions**:
1. Verify the image exists:
   ```bash
   ibmcloud cr images --restrict test_icr
   ```

2. Check the image path format:
   - Correct: `icr.io/test_icr/ibm-cloud-info:latest`
   - Incorrect: `icr.io/test_icr/ibm-cloud-info` (missing tag)

### Avoiding Resource Recreation

If Terraform wants to recreate resources unnecessarily:

1. **Check the state**:
   ```bash
   terraform state list
   ```

2. **Import existing resources** (see Import section above)

3. **Use targeted apply** to update only specific resources:
   ```bash
   terraform apply -target=ibm_code_engine_secret.registry_secret
   terraform apply -target=ibm_code_engine_app.app
   ```

## Best Practices

1. **API Key Security**:
   - Never commit `terraform.tfvars` with real API keys
   - Use environment variables or secret management tools
   - Rotate API keys regularly

2. **Secret Naming**:
   - Use descriptive names like `icr-secret` or `registry-secret`
   - Keep names consistent across environments

3. **Image Tags**:
   - Use specific tags instead of `latest` for production
   - Example: `icr.io/test_icr/ibm-cloud-info:v1.0.0`

4. **State Management**:
   - Use remote state (IBM Cloud Object Storage, Terraform Cloud)
   - Enable state locking to prevent concurrent modifications

## Additional Resources

- [IBM Cloud Code Engine Documentation](https://cloud.ibm.com/docs/codeengine)
- [IBM Container Registry Documentation](https://cloud.ibm.com/docs/Registry)
- [Terraform IBM Provider Documentation](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)

## Example Complete Workflow

```bash
# 1. Set up variables
cat > terraform.tfvars <<EOF
ibmcloud_api_key = "your-api-key"
region = "us-south"
project_name = "ibm-cloud-info"
app_name = "ibm-cloud-info-app"
container_image = "icr.io/test_icr/ibm-cloud-info:latest"
EOF

# 2. Initialize Terraform
terraform init

# 3. Plan changes
terraform plan -out=tfplan

# 4. Review the plan
# Look for:
# - ibm_code_engine_secret.registry_secret will be created
# - ibm_code_engine_app.app will be created/updated

# 5. Apply changes
terraform apply -auto-approve -input=false tfplan

# 6. Verify deployment
terraform output app_url
curl $(terraform output -raw app_url)

# 7. Check application logs if needed
ibmcloud ce project select --name ibm-cloud-info
ibmcloud ce app logs --name ibm-cloud-info-app
```

## Summary

The updated Terraform configuration now:
- ✅ Creates a registry secret for IBM Container Registry authentication
- ✅ Uses your IBM Cloud API key securely
- ✅ Associates the secret with the Code Engine application
- ✅ Ensures proper dependency ordering
- ✅ Uses recommended `project.id` reference

Your application should now successfully pull private images from IBM Container Registry.