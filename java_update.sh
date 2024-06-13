#!/bin/bash

# Configuration Variables
REPO_URL="https://github.com/interactinteractive-php/java_war.git"
TARGET_DIR="/tmp/repo_clone"  
WAR_FILE_NAME="erp-services-1.0.war"  
PAYARA_CONTAINER_NAME="payara_container"  
PAYARA_DEPLOY_DIR="/opt/payara/deployments" 
PAYARA_BIN_DIR="/opt/payara/appserver/bin"  
PHP_CONTAINER_NAME="php_container"  

check_git_installed() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Installing Git..."
        sudo yum install -y git
        if [ $? -ne 0 ]; then
            echo "Failed to install Git. Please install Git manually and try again."
            exit 1
        fi
    fi
}

clone_repository() {
    if [ -d "$TARGET_DIR" ]; then
        echo "Cleaning up existing directory..."
        rm -rf "$TARGET_DIR"
    fi
    echo "Cloning repository..."
    git clone "$REPO_URL" "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository."
        exit 1
    fi
}

copy_war_to_payara_container() {
    if [ ! -f "$TARGET_DIR/$WAR_FILE_NAME" ]; then
        echo "WAR file not found in the repository."
        exit 1
    fi
    echo "Copying WAR file to Payara container..."
    docker cp "$TARGET_DIR/$WAR_FILE_NAME" "$PAYARA_CONTAINER_NAME:$PAYARA_DEPLOY_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to copy WAR file to Payara container."
        exit 1
    fi
}

restart_payara_container() {
    echo "Restarting Payara server in container..."
    docker exec "$PAYARA_CONTAINER_NAME" "$PAYARA_BIN_DIR/asadmin" stop-domain
    docker exec "$PAYARA_CONTAINER_NAME" "$PAYARA_BIN_DIR/asadmin" start-domain
    if [ $? -ne 0 ]; then
        echo "Failed to restart Payara server."
        exit 1
    fi
}

# Run the functions inside the PHP container
docker exec "$PHP_CONTAINER_NAME" bash -c "
$(declare -f check_git_installed)
$(declare -f clone_repository)
check_git_installed
clone_repository
"

copy_war_to_payara_container
restart_payara_container

echo "Deployment completed successfully."
