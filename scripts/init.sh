#!/bin/bash

# IBM Cloud Info - Initialization Script
# This script helps you set up the project for the first time

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

# Main script
clear
print_header "IBM Cloud Info - Project Initialization"
echo ""

# Check prerequisites
print_header "Checking Prerequisites"
echo ""

MISSING_DEPS=0

if ! check_command "ibmcloud"; then
    print_info "Install from: https://cloud.ibm.com/docs/cli"
    MISSING_DEPS=1
fi

if ! check_command "terraform"; then
    print_info "Install from: https://www.terraform.io/downloads"
    MISSING_DEPS=1
fi

if ! check_command "docker"; then
    print_info "Install from: https://docs.docker.com/get-docker/"
    MISSING_DEPS=1
fi

if ! check_command "git"; then
    print_info "Install from: https://git-scm.com/downloads"
    MISSING_DEPS=1
fi

echo ""

if [ $MISSING_DEPS -eq 1 ]; then
    print_error "Please install missing dependencies and run this script again"
    exit 1
fi

print_success "All prerequisites are installed!"
echo ""

# IBM Cloud login
print_header "IBM Cloud Configuration"
echo ""

read -p "Do you want to login to IBM Cloud now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ibmcloud login
    print_success "Logged in to IBM Cloud"
else
    print_warning "Skipping IBM Cloud login"
fi

echo ""

# Create API Key
read -p "Do you want to create a new API Key? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter a name for your API Key (default: terraform-key): " API_KEY_NAME
    API_KEY_NAME=${API_KEY_NAME:-terraform-key}
    
    print_info "Creating API Key..."
    API_KEY_OUTPUT=$(ibmcloud iam api-key-create $API_KEY_NAME -d "API key for Terraform deployment" --output json)
    API_KEY=$(echo $API_KEY_OUTPUT | grep -o '"apikey":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$API_KEY" ]; then
        print_success "API Key created successfully!"
        print_warning "IMPORTANT: Save this API Key, you won't be able to see it again:"
        echo ""
        echo -e "${YELLOW}$API_KEY${NC}"
        echo ""
        read -p "Press Enter after you've saved the API Key..."
    else
        print_error "Failed to create API Key"
    fi
else
    print_warning "Skipping API Key creation"
fi

echo ""

# Container Registry setup
print_header "Container Registry Configuration"
echo ""

read -p "Do you want to set up Container Registry? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter region (default: us-south): " CR_REGION
    CR_REGION=${CR_REGION:-us-south}
    
    print_info "Setting Container Registry region to $CR_REGION..."
    ibmcloud cr region-set $CR_REGION
    
    read -p "Enter a unique namespace name: " CR_NAMESPACE
    
    if [ -n "$CR_NAMESPACE" ]; then
        print_info "Creating namespace $CR_NAMESPACE..."
        if ibmcloud cr namespace-add $CR_NAMESPACE; then
            print_success "Namespace created successfully!"
        else
            print_error "Failed to create namespace (it might already exist)"
        fi
    else
        print_warning "No namespace provided, skipping"
    fi
else
    print_warning "Skipping Container Registry setup"
fi

echo ""

# Terraform configuration
print_header "Terraform Configuration"
echo ""

read -p "Do you want to create terraform.tfvars file? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "terraform/terraform.tfvars" ]; then
        print_warning "terraform.tfvars already exists"
        read -p "Do you want to overwrite it? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Keeping existing terraform.tfvars"
        else
            cp terraform/terraform.tfvars.example terraform/terraform.tfvars
            print_success "Created terraform/terraform.tfvars from example"
            print_warning "Please edit terraform/terraform.tfvars with your actual values"
        fi
    else
        cp terraform/terraform.tfvars.example terraform/terraform.tfvars
        print_success "Created terraform/terraform.tfvars from example"
        print_warning "Please edit terraform/terraform.tfvars with your actual values"
    fi
else
    print_warning "Skipping terraform.tfvars creation"
fi

echo ""

# GitHub Secrets reminder
print_header "GitHub Secrets Configuration"
echo ""
print_info "Don't forget to configure GitHub Secrets for CI/CD:"
echo ""
echo "Go to: Settings > Secrets and variables > Actions"
echo ""
echo "Required secrets:"
echo "  - IBM_CLOUD_API_KEY"
echo "  - IBM_CLOUD_REGION"
echo "  - IBM_CLOUD_RESOURCE_GROUP"
echo "  - ICR_NAMESPACE"
echo ""

# Summary
print_header "Setup Summary"
echo ""
print_info "Next steps:"
echo ""
echo "1. Edit terraform/terraform.tfvars with your values"
echo "2. Configure GitHub Secrets (if using GitHub Actions)"
echo "3. Test locally with: docker build -t test ."
echo "4. Deploy with: cd terraform && terraform init && terraform apply"
echo "5. Or push to GitHub to trigger automatic deployment"
echo ""
print_success "Initialization complete!"
echo ""
print_info "For detailed instructions, see SETUP_GUIDE.md"
echo ""

# Made with Bob
