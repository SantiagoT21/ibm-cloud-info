#!/bin/bash

# Script to fix disabled Code Engine project
# A disabled project cannot be used and must be re-enabled

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
        REGION=$(grep 'region' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
    fi
    
    if [ -z "$PROJECT_NAME" ]; then
        read -p "Enter Code Engine project name: " PROJECT_NAME
    fi
    
    if [ -z "$REGION" ]; then
        read -p "Enter region (e.g., us-south): " REGION
    fi
}

# Check project status
check_project_status() {
    print_header "Checking Project Status"
    
    print_info "Project: $PROJECT_NAME"
    print_info "Region: $REGION"
    
    # Target the correct region
    ibmcloud target -r "$REGION"
    
    # Get project details
    if ibmcloud ce project get --name "$PROJECT_NAME" 2>&1 | grep -q "disabled"; then
        print_error "Project is DISABLED"
        return 1
    elif ibmcloud ce project get --name "$PROJECT_NAME" &> /dev/null; then
        print_success "Project is ACTIVE"
        ibmcloud ce project get --name "$PROJECT_NAME"
        return 0
    else
        print_error "Project not found"
        return 2
    fi
}

# Delete disabled project
delete_disabled_project() {
    print_header "Deleting Disabled Project"
    
    print_warning "A disabled project cannot be re-enabled, it must be deleted and recreated"
    print_warning "This will delete ALL resources in the project:"
    echo "  - Applications"
    echo "  - Jobs"
    echo "  - Secrets"
    echo "  - ConfigMaps"
    echo ""
    
    read -p "Are you sure you want to delete the project '$PROJECT_NAME'? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Deletion cancelled"
        return 1
    fi
    
    print_info "Deleting project..."
    
    if ibmcloud ce project delete --name "$PROJECT_NAME" --force --hard; then
        print_success "Project deleted successfully"
        print_info "Waiting 30 seconds for cleanup..."
        sleep 30
        return 0
    else
        print_error "Failed to delete project"
        return 1
    fi
}

# Recreate project with Terraform
recreate_with_terraform() {
    print_header "Recreating Project with Terraform"
    
    print_info "Removing project from Terraform state..."
    cd terraform
    
    # Remove from state if exists
    if terraform state list | grep -q "ibm_code_engine_project.project"; then
        terraform state rm ibm_code_engine_project.project || true
    fi
    
    print_info "Planning Terraform changes..."
    terraform plan -out=tfplan
    
    print_info "Applying Terraform..."
    if terraform apply -auto-approve -input=false tfplan; then
        print_success "Project recreated successfully with Terraform"
        cd ..
        return 0
    else
        print_error "Failed to recreate project with Terraform"
        cd ..
        return 1
    fi
}

# Manual project creation
create_project_manually() {
    print_header "Creating Project Manually"
    
    print_info "Creating project '$PROJECT_NAME' in region '$REGION'..."
    
    if ibmcloud ce project create --name "$PROJECT_NAME"; then
        print_success "Project created successfully"
        
        print_info "Importing project into Terraform state..."
        cd terraform
        
        # Get project ID
        PROJECT_ID=$(ibmcloud ce project get --name "$PROJECT_NAME" --output json | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$PROJECT_ID" ]; then
            print_info "Project ID: $PROJECT_ID"
            terraform import ibm_code_engine_project.project "$PROJECT_ID"
            print_success "Project imported into Terraform state"
        fi
        
        cd ..
        return 0
    else
        print_error "Failed to create project manually"
        return 1
    fi
}

# Show menu
show_menu() {
    echo ""
    echo "=================================="
    echo "Fix Disabled Code Engine Project"
    echo "=================================="
    echo "1. Check project status"
    echo "2. Delete disabled project"
    echo "3. Delete and recreate with Terraform (Recommended)"
    echo "4. Delete and recreate manually"
    echo "5. Full automated fix (delete + recreate + deploy)"
    echo "6. Exit"
    echo "=================================="
}

# Full automated fix
full_automated_fix() {
    print_header "Full Automated Fix"
    
    print_info "This will:"
    echo "  1. Delete the disabled project"
    echo "  2. Remove it from Terraform state"
    echo "  3. Recreate it with Terraform"
    echo "  4. Deploy all resources (project, secret, app)"
    echo ""
    
    read -p "Continue with full automated fix? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Cancelled"
        return 1
    fi
    
    # Step 1: Delete project
    print_info "Step 1/4: Deleting disabled project..."
    if ibmcloud ce project delete --name "$PROJECT_NAME" --force --hard; then
        print_success "Project deleted"
    else
        print_warning "Project may not exist or already deleted"
    fi
    
    sleep 10
    
    # Step 2: Clean Terraform state
    print_info "Step 2/4: Cleaning Terraform state..."
    cd terraform
    terraform state rm ibm_code_engine_project.project 2>/dev/null || true
    terraform state rm ibm_code_engine_secret.registry_secret 2>/dev/null || true
    terraform state rm ibm_code_engine_app.app 2>/dev/null || true
    cd ..
    print_success "Terraform state cleaned"
    
    # Step 3: Recreate with Terraform
    print_info "Step 3/4: Recreating with Terraform..."
    cd terraform
    terraform plan -out=tfplan
    
    if terraform apply -auto-approve -input=false tfplan; then
        print_success "Resources created successfully"
        cd ..
    else
        print_error "Terraform apply failed"
        cd ..
        return 1
    fi
    
    # Step 4: Verify
    print_info "Step 4/4: Verifying deployment..."
    sleep 5
    
    if ibmcloud ce project get --name "$PROJECT_NAME" &> /dev/null; then
        print_success "Project is active"
        ibmcloud ce project select --name "$PROJECT_NAME"
        
        print_info "Checking secret..."
        if ibmcloud ce secret get --name icr-secret &> /dev/null; then
            print_success "Secret created"
        else
            print_warning "Secret not found"
        fi
        
        print_info "Checking app..."
        APP_NAME=$(grep 'app_name' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
        if ibmcloud ce app get --name "$APP_NAME" &> /dev/null; then
            print_success "App deployed"
            ibmcloud ce app get --name "$APP_NAME"
        else
            print_warning "App not found or still deploying"
        fi
    else
        print_error "Project verification failed"
        return 1
    fi
    
    print_success "Full automated fix completed!"
}

# Main function
main() {
    print_header "Code Engine Disabled Project Fix"
    
    load_variables
    
    while true; do
        show_menu
        read -p "Select an option (1-6): " choice
        
        case $choice in
            1)
                check_project_status
                ;;
            2)
                delete_disabled_project
                ;;
            3)
                if delete_disabled_project; then
                    recreate_with_terraform
                fi
                ;;
            4)
                if delete_disabled_project; then
                    create_project_manually
                fi
                ;;
            5)
                full_automated_fix
                ;;
            6)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-6."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main
main

# Made with Bob
