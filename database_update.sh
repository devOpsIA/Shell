#!/bin/bash

DB_REPO_URL="https://github.com/devOpsIA/Database.git"
TARGET_DB_DIR="/var/www/html/html/php_erp/storage"  

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
    if [ -d "$TARGET_DB_DIR" ]; then
        echo "Cleaning up existing directory..."
        rm -rf "$TARGET_DB_DIR"
    fi
    echo "Cloning database repository..."
    git clone "$DB_REPO_URL" "$TARGET_DB_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository."
        exit 1
    fi
}

check_git_installed
clone_repository

echo "Database repository cloned successfully."
