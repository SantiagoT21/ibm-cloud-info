#!/bin/bash

# Script to build and push Docker/Podman image to IBM Container Registry
# Supports both Docker and Podman

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

# Detect container runtime (Docker or Podman)
detect_runtime() {
    if command -v docker &> /dev/null; then
        RUNTIME="docker"
        print_success "Using Docker"
    elif command -v podman &> /dev/null; then
        RUNTIME="podman"
        print_success "Using Podman"
    else
        print_error "Neither Docker nor Podman found. Please install one of them."
        exit 1
    fi
}

# Load variables from terraform.tfvars
load_variables() {
    if [ -f "terraform/terraform.tfvars" ]; then
        CONTAINER_IMAGE=$(grep 'container_image' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
        REGION=$(grep 'region' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
    fi
    
    if [ -z "$CONTAINER_IMAGE" ]; then
        print_warning "Container image not found in terraform.tfvars"
        read -p "Enter full image name (e.g., icr.io/namespace/image:tag): " CONTAINER_IMAGE
    fi
    
    # Extract components
    REGISTRY=$(echo $CONTAINER_IMAGE | cut -d'/' -f1)
    NAMESPACE=$(echo $CONTAINER_IMAGE | cut -d'/' -f2)
    IMAGE_NAME=$(echo $CONTAINER_IMAGE | cut -d'/' -f3 | cut -d':' -f1)
    TAG=$(echo $CONTAINER_IMAGE | cut -d':' -f2)
    
    if [ "$TAG" = "$CONTAINER_IMAGE" ]; then
        TAG="latest"
    fi
    
    print_info "Registry: $REGISTRY"
    print_info "Namespace: $NAMESPACE"
    print_info "Image: $IMAGE_NAME"
    print_info "Tag: $TAG"
}

# Check IBM Cloud CLI authentication
check_auth() {
    print_header "Checking IBM Cloud Authentication"
    
    if ! ibmcloud target &> /dev/null; then
        print_error "Not authenticated to IBM Cloud"
        print_info "Please run: ibmcloud login --sso"
        exit 1
    fi
    
    print_success "Authenticated to IBM Cloud"
    ibmcloud target
}

# Login to IBM Container Registry
login_registry() {
    print_header "Logging into IBM Container Registry"
    
    if ibmcloud cr login; then
        print_success "Logged into Container Registry"
    else
        print_error "Failed to login to Container Registry"
        exit 1
    fi
}

# Check if namespace exists, create if not
check_namespace() {
    print_header "Checking Namespace"
    
    if ibmcloud cr namespace-list | grep -q "^${NAMESPACE}$"; then
        print_success "Namespace '$NAMESPACE' exists"
    else
        print_warning "Namespace '$NAMESPACE' not found"
        read -p "Create namespace '$NAMESPACE'? (yes/no): " create_ns
        
        if [ "$create_ns" = "yes" ]; then
            if ibmcloud cr namespace-add "$NAMESPACE"; then
                print_success "Namespace created"
            else
                print_error "Failed to create namespace"
                exit 1
            fi
        else
            print_error "Cannot proceed without namespace"
            exit 1
        fi
    fi
}

# Build the image
build_image() {
    print_header "Building Container Image"
    
    print_info "Building $CONTAINER_IMAGE..."
    print_info "This may take a few minutes..."
    
    if [ "$RUNTIME" = "docker" ]; then
        if docker build -t "$CONTAINER_IMAGE" .; then
            print_success "Image built successfully with Docker"
        else
            print_error "Docker build failed"
            exit 1
        fi
    else
        if podman build -t "$CONTAINER_IMAGE" .; then
            print_success "Image built successfully with Podman"
        else
            print_error "Podman build failed"
            exit 1
        fi
    fi
    
    # Show image details
    print_info "Image details:"
    if [ "$RUNTIME" = "docker" ]; then
        docker images | grep "$IMAGE_NAME"
    else
        podman images | grep "$IMAGE_NAME"
    fi
}

# Test the image locally
test_image() {
    print_header "Testing Image Locally"
    
    read -p "Test the image locally before pushing? (yes/no): " test_local
    
    if [ "$test_local" != "yes" ]; then
        print_info "Skipping local test"
        return 0
    fi
    
    print_info "Starting container on port 8080..."
    
    # Stop any existing container
    if [ "$RUNTIME" = "docker" ]; then
        docker stop test-container 2>/dev/null || true
        docker rm test-container 2>/dev/null || true
        docker run -d --name test-container -p 8080:8080 "$CONTAINER_IMAGE"
    else
        podman stop test-container 2>/dev/null || true
        podman rm test-container 2>/dev/null || true
        podman run -d --name test-container -p 8080:8080 "$CONTAINER_IMAGE"
    fi
    
    print_info "Waiting for container to start..."
    sleep 5
    
    print_info "Testing HTTP endpoint..."
    if curl -f http://localhost:8080 > /dev/null 2>&1; then
        print_success "Container is responding correctly!"
        print_info "View in browser: http://localhost:8080"
    else
        print_error "Container is not responding"
        print_info "Check logs:"
        if [ "$RUNTIME" = "docker" ]; then
            docker logs test-container
        else
            podman logs test-container
        fi
    fi
    
    read -p "Press Enter to stop test container and continue..."
    
    if [ "$RUNTIME" = "docker" ]; then
        docker stop test-container
        docker rm test-container
    else
        podman stop test-container
        podman rm test-container
    fi
}

# Push image to registry
push_image() {
    print_header "Pushing Image to IBM Container Registry"
    
    print_info "Pushing $CONTAINER_IMAGE..."
    print_info "This may take a few minutes depending on image size..."
    
    if [ "$RUNTIME" = "docker" ]; then
        if docker push "$CONTAINER_IMAGE"; then
            print_success "Image pushed successfully"
        else
            print_error "Failed to push image"
            exit 1
        fi
    else
        if podman push "$CONTAINER_IMAGE"; then
            print_success "Image pushed successfully"
        else
            print_error "Failed to push image"
            exit 1
        fi
    fi
}

# Verify image in registry
verify_image() {
    print_header "Verifying Image in Registry"
    
    print_info "Checking if image is available in registry..."
    sleep 3
    
    if ibmcloud cr images --restrict "$NAMESPACE/$IMAGE_NAME" | grep -q "$IMAGE_NAME"; then
        print_success "Image verified in registry!"
        ibmcloud cr images --restrict "$NAMESPACE/$IMAGE_NAME"
    else
        print_error "Image not found in registry"
        exit 1
    fi
}

# Scan image for vulnerabilities
scan_image() {
    print_header "Scanning Image for Vulnerabilities"
    
    read -p "Scan image for vulnerabilities? (yes/no): " scan
    
    if [ "$scan" != "yes" ]; then
        print_info "Skipping vulnerability scan"
        return 0
    fi
    
    print_info "Running vulnerability scan..."
    ibmcloud cr vulnerability-assessment "$CONTAINER_IMAGE" || true
}

# Show next steps
show_next_steps() {
    print_header "Next Steps"
    
    echo ""
    print_success "Image successfully built and pushed!"
    echo ""
    print_info "Image: $CONTAINER_IMAGE"
    echo ""
    print_info "Now you can deploy with Terraform:"
    echo ""
    echo "  cd terraform"
    echo "  terraform plan -out=tfplan"
    echo "  terraform apply -auto-approve -input=false tfplan"
    echo ""
    print_info "Or use the automated deployment script:"
    echo ""
    echo "  ./scripts/fix-disabled-project.sh"
    echo "  # Select option 5 (Full automated fix)"
    echo ""
    print_info "To verify the image:"
    echo ""
    echo "  ibmcloud cr images --restrict $NAMESPACE/$IMAGE_NAME"
    echo ""
    print_info "To pull and test locally:"
    echo ""
    echo "  $RUNTIME pull $CONTAINER_IMAGE"
    echo "  $RUNTIME run -p 8080:8080 $CONTAINER_IMAGE"
    echo ""
}

# Main function
main() {
    print_header "Build and Push Container Image"
    
    detect_runtime
    load_variables
    check_auth
    login_registry
    check_namespace
    build_image
    test_image
    push_image
    verify_image
    scan_image
    show_next_steps
    
    print_success "All done!"
}

# Run main function
main

# Made with Bob
