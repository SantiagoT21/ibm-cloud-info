#!/bin/bash

# Script to manage Code Engine applications before Terraform deployment
# This helps handle existing apps that might conflict with Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
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

# Check if required commands are available
check_requirements() {
    if ! command -v ibmcloud &> /dev/null; then
        print_error "IBM Cloud CLI not found. Please install it first."
        exit 1
    fi

    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not found. Please install it first."
        exit 1
    fi

    # Check if Code Engine plugin is installed
    if ! ibmcloud plugin list | grep -q "code-engine"; then
        print_error "Code Engine plugin not installed. Install with: ibmcloud plugin install code-engine"
        exit 1
    fi
}

# Function to check if app exists
check_app_exists() {
    local project_name=$1
    local app_name=$2
    
    print_info "Checking if app '${app_name}' exists in project '${project_name}'..."
    
    # Select the project
    if ! ibmcloud ce project select --name "${project_name}" &> /dev/null; then
        print_warning "Project '${project_name}' not found or not accessible"
        return 1
    fi
    
    # Check if app exists
    if ibmcloud ce app get --name "${app_name}" &> /dev/null; then
        print_success "App '${app_name}' exists"
        return 0
    else
        print_info "App '${app_name}' does not exist"
        return 1
    fi
}

# Function to delete existing app
delete_app() {
    local project_name=$1
    local app_name=$2
    
    print_warning "Deleting app '${app_name}' from project '${project_name}'..."
    
    ibmcloud ce project select --name "${project_name}"
    
    if ibmcloud ce app delete --name "${app_name}" --force --wait; then
        print_success "App '${app_name}' deleted successfully"
        return 0
    else
        print_error "Failed to delete app '${app_name}'"
        return 1
    fi
}

# Function to import app into Terraform state
import_app() {
    local project_name=$1
    local app_name=$2
    
    print_info "Importing app '${app_name}' into Terraform state..."
    
    # Get project ID
    ibmcloud ce project select --name "${project_name}"
    local project_id=$(ibmcloud ce project current --output json | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "${project_id}" ]; then
        print_error "Could not get project ID"
        return 1
    fi
    
    print_info "Project ID: ${project_id}"
    
    # Import the app
    cd terraform
    if terraform import ibm_code_engine_app.app "${project_id}/${app_name}"; then
        print_success "App imported successfully into Terraform state"
        cd ..
        return 0
    else
        print_error "Failed to import app into Terraform state"
        cd ..
        return 1
    fi
}

# Function to show app details
show_app_details() {
    local project_name=$1
    local app_name=$2
    
    print_info "App details:"
    ibmcloud ce project select --name "${project_name}"
    ibmcloud ce app get --name "${app_name}"
}

# Main menu
show_menu() {
    echo ""
    echo "=================================="
    echo "Code Engine App Management"
    echo "=================================="
    echo "1. Check if app exists"
    echo "2. Delete existing app"
    echo "3. Import app to Terraform"
    echo "4. Show app details"
    echo "5. Delete and run Terraform apply"
    echo "6. Import and run Terraform apply"
    echo "7. Exit"
    echo "=================================="
}

# Main script
main() {
    check_requirements
    
    # Load variables from terraform.tfvars if exists
    if [ -f "terraform/terraform.tfvars" ]; then
        PROJECT_NAME=$(grep 'project_name' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
        APP_NAME=$(grep 'app_name' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
    fi
    
    # Prompt for project and app names if not found
    if [ -z "${PROJECT_NAME}" ]; then
        read -p "Enter Code Engine project name: " PROJECT_NAME
    else
        print_info "Using project name from terraform.tfvars: ${PROJECT_NAME}"
    fi
    
    if [ -z "${APP_NAME}" ]; then
        read -p "Enter Code Engine app name: " APP_NAME
    else
        print_info "Using app name from terraform.tfvars: ${APP_NAME}"
    fi
    
    while true; do
        show_menu
        read -p "Select an option (1-7): " choice
        
        case $choice in
            1)
                check_app_exists "${PROJECT_NAME}" "${APP_NAME}"
                ;;
            2)
                if check_app_exists "${PROJECT_NAME}" "${APP_NAME}"; then
                    read -p "Are you sure you want to delete the app? (yes/no): " confirm
                    if [ "${confirm}" = "yes" ]; then
                        delete_app "${PROJECT_NAME}" "${APP_NAME}"
                    else
                        print_info "Deletion cancelled"
                    fi
                fi
                ;;
            3)
                if check_app_exists "${PROJECT_NAME}" "${APP_NAME}"; then
                    import_app "${PROJECT_NAME}" "${APP_NAME}"
                else
                    print_warning "App does not exist, nothing to import"
                fi
                ;;
            4)
                if check_app_exists "${PROJECT_NAME}" "${APP_NAME}"; then
                    show_app_details "${PROJECT_NAME}" "${APP_NAME}"
                fi
                ;;
            5)
                if check_app_exists "${PROJECT_NAME}" "${APP_NAME}"; then
                    read -p "This will delete the app and run Terraform apply. Continue? (yes/no): " confirm
                    if [ "${confirm}" = "yes" ]; then
                        delete_app "${PROJECT_NAME}" "${APP_NAME}"
                        print_info "Running Terraform apply..."
                        cd terraform
                        terraform plan -out=tfplan
                        terraform apply -auto-approve -input=false tfplan
                        cd ..
                        print_success "Deployment complete!"
                    fi
                else
                    print_info "App does not exist, running Terraform apply..."
                    cd terraform
                    terraform plan -out=tfplan
                    terraform apply -auto-approve -input=false tfplan
                    cd ..
                    print_success "Deployment complete!"
                fi
                ;;
            6)
                if check_app_exists "${PROJECT_NAME}" "${APP_NAME}"; then
                    import_app "${PROJECT_NAME}" "${APP_NAME}"
                    print_info "Running Terraform apply..."
                    cd terraform
                    terraform plan -out=tfplan
                    terraform apply -auto-approve -input=false tfplan
                    cd ..
                    print_success "Deployment complete!"
                else
                    print_info "App does not exist, running Terraform apply..."
                    cd terraform
                    terraform plan -out=tfplan
                    terraform apply -auto-approve -input=false tfplan
                    cd ..
                    print_success "Deployment complete!"
                fi
                ;;
            7)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-7."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main

# Made with Bob
