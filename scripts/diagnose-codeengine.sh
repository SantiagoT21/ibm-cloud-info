#!/bin/bash

# Script to diagnose Code Engine deployment issues
# Helps identify problems with image access, secrets, and app configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_header() {
    echo ""
    echo "=================================="
    echo "$1"
    echo "=================================="
}

# Load variables from terraform.tfvars
load_variables() {
    if [ -f "terraform/terraform.tfvars" ]; then
        PROJECT_NAME=$(grep 'project_name' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
        APP_NAME=$(grep 'app_name' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
        CONTAINER_IMAGE=$(grep 'container_image' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
        REGION=$(grep 'region' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
    fi
}

# Check IBM Cloud CLI authentication
check_auth() {
    print_header "1. Checking IBM Cloud Authentication"
    
    if ibmcloud target &> /dev/null; then
        print_success "Authenticated to IBM Cloud"
        ibmcloud target
    else
        print_error "Not authenticated to IBM Cloud"
        print_info "Run: ibmcloud login --sso"
        exit 1
    fi
}

# Check Container Registry access
check_registry_access() {
    print_header "2. Checking Container Registry Access"
    
    if [ -z "$CONTAINER_IMAGE" ]; then
        print_warning "Container image not found in terraform.tfvars"
        read -p "Enter container image (e.g., icr.io/namespace/image:tag): " CONTAINER_IMAGE
    fi
    
    print_info "Checking image: $CONTAINER_IMAGE"
    
    # Extract namespace from image
    NAMESPACE=$(echo $CONTAINER_IMAGE | cut -d'/' -f2)
    IMAGE_NAME=$(echo $CONTAINER_IMAGE | cut -d'/' -f3 | cut -d':' -f1)
    
    print_info "Namespace: $NAMESPACE"
    print_info "Image name: $IMAGE_NAME"
    
    # Try to login to ICR
    print_info "Logging into Container Registry..."
    if ibmcloud cr login; then
        print_success "Logged into Container Registry"
    else
        print_error "Failed to login to Container Registry"
        return 1
    fi
    
    # Check if namespace exists
    print_info "Checking namespace..."
    if ibmcloud cr namespace-list | grep -q "$NAMESPACE"; then
        print_success "Namespace '$NAMESPACE' exists"
    else
        print_error "Namespace '$NAMESPACE' not found"
        print_info "Available namespaces:"
        ibmcloud cr namespace-list
        return 1
    fi
    
    # Check if image exists
    print_info "Checking if image exists..."
    if ibmcloud cr images --restrict "$NAMESPACE/$IMAGE_NAME" | grep -q "$IMAGE_NAME"; then
        print_success "Image found in registry"
        ibmcloud cr images --restrict "$NAMESPACE/$IMAGE_NAME"
    else
        print_error "Image not found in registry"
        print_info "Available images in namespace:"
        ibmcloud cr images --restrict "$NAMESPACE"
        return 1
    fi
}

# Check Code Engine project
check_project() {
    print_header "3. Checking Code Engine Project"
    
    if [ -z "$PROJECT_NAME" ]; then
        print_warning "Project name not found in terraform.tfvars"
        read -p "Enter project name: " PROJECT_NAME
    fi
    
    print_info "Checking project: $PROJECT_NAME"
    
    if ibmcloud ce project get --name "$PROJECT_NAME" &> /dev/null; then
        print_success "Project '$PROJECT_NAME' exists"
        ibmcloud ce project select --name "$PROJECT_NAME"
        ibmcloud ce project current
    else
        print_warning "Project '$PROJECT_NAME' not found"
        print_info "Available projects:"
        ibmcloud ce project list
        return 1
    fi
}

# Check registry secret
check_secret() {
    print_header "4. Checking Registry Secret"
    
    if ! ibmcloud ce project get --name "$PROJECT_NAME" &> /dev/null; then
        print_error "Project not selected"
        return 1
    fi
    
    ibmcloud ce project select --name "$PROJECT_NAME"
    
    print_info "Checking for registry secret 'icr-secret'..."
    
    if ibmcloud ce secret get --name "icr-secret" &> /dev/null; then
        print_success "Registry secret 'icr-secret' exists"
        ibmcloud ce secret get --name "icr-secret"
    else
        print_warning "Registry secret 'icr-secret' not found"
        print_info "Available secrets:"
        ibmcloud ce secret list
        return 1
    fi
}

# Check application status
check_app() {
    print_header "5. Checking Application Status"
    
    if [ -z "$APP_NAME" ]; then
        print_warning "App name not found in terraform.tfvars"
        read -p "Enter app name: " APP_NAME
    fi
    
    ibmcloud ce project select --name "$PROJECT_NAME"
    
    print_info "Checking app: $APP_NAME"
    
    if ibmcloud ce app get --name "$APP_NAME" &> /dev/null; then
        print_success "App '$APP_NAME' exists"
        ibmcloud ce app get --name "$APP_NAME"
        
        echo ""
        print_info "Recent app events:"
        ibmcloud ce app events --app "$APP_NAME"
        
        echo ""
        print_info "Recent app logs:"
        ibmcloud ce app logs --app "$APP_NAME" --tail 50
    else
        print_warning "App '$APP_NAME' not found"
        print_info "Available apps:"
        ibmcloud ce app list
        return 1
    fi
}

# Test image pull manually
test_image_pull() {
    print_header "6. Testing Image Pull Locally"
    
    if [ -z "$CONTAINER_IMAGE" ]; then
        print_warning "Container image not specified"
        return 1
    fi
    
    print_info "Attempting to pull image locally..."
    print_warning "This requires Docker or Podman to be installed"
    
    if command -v docker &> /dev/null; then
        print_info "Using Docker..."
        if docker pull "$CONTAINER_IMAGE"; then
            print_success "Successfully pulled image with Docker"
            docker images | grep "$IMAGE_NAME"
        else
            print_error "Failed to pull image with Docker"
            print_info "Try: ibmcloud cr login && docker pull $CONTAINER_IMAGE"
        fi
    elif command -v podman &> /dev/null; then
        print_info "Using Podman..."
        if podman pull "$CONTAINER_IMAGE"; then
            print_success "Successfully pulled image with Podman"
            podman images | grep "$IMAGE_NAME"
        else
            print_error "Failed to pull image with Podman"
            print_info "Try: ibmcloud cr login && podman pull $CONTAINER_IMAGE"
        fi
    else
        print_warning "Neither Docker nor Podman found, skipping local pull test"
    fi
}

# Check IAM permissions
check_iam_permissions() {
    print_header "7. Checking IAM Permissions"
    
    print_info "Current user/service ID:"
    ibmcloud iam oauth-tokens
    
    print_info "Checking access policies..."
    print_info "You should have at least:"
    echo "  - Viewer role on Container Registry"
    echo "  - Editor role on Code Engine"
    echo "  - Reader role on Resource Group"
}

# Provide recommendations
provide_recommendations() {
    print_header "Recommendations"
    
    echo "Based on the diagnostics, here are some recommendations:"
    echo ""
    echo "1. If image not found:"
    echo "   - Verify the image exists: ibmcloud cr images"
    echo "   - Check the image path in terraform.tfvars"
    echo "   - Ensure the tag exists (e.g., :latest, :v1.0.0)"
    echo ""
    echo "2. If authentication fails:"
    echo "   - Recreate the registry secret with correct API key"
    echo "   - Verify API key has Container Registry access"
    echo "   - Check: ibmcloud iam api-keys"
    echo ""
    echo "3. If app deployment times out:"
    echo "   - Check app logs: ibmcloud ce app logs --app $APP_NAME"
    echo "   - Verify the container starts correctly locally"
    echo "   - Check if the app listens on the correct port"
    echo "   - Increase timeout in Terraform (already set to 20m)"
    echo ""
    echo "4. If secret not found:"
    echo "   - Run: terraform apply to create the secret"
    echo "   - Or create manually: ibmcloud ce secret create --name icr-secret --format registry ..."
    echo ""
    echo "5. Common fixes:"
    echo "   - Delete and recreate: ./scripts/manage-codeengine-app.sh (option 5)"
    echo "   - Import existing app: ./scripts/manage-codeengine-app.sh (option 6)"
    echo "   - Check Terraform state: cd terraform && terraform state list"
}

# Main execution
main() {
    echo "=================================="
    echo "Code Engine Deployment Diagnostics"
    echo "=================================="
    
    load_variables
    
    check_auth
    check_registry_access
    check_project
    check_secret
    check_app
    test_image_pull
    check_iam_permissions
    provide_recommendations
    
    echo ""
    print_success "Diagnostics complete!"
}

# Run main function
main

# Made with Bob
