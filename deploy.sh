#!/usr/bin/env bash

################################################################################
# FastDeploy
#
# Main deployment entry point
#
# Responsibilities:
#   - Load configuration
#   - Perform sanity checks
#   - Call deployment modules
#
################################################################################

set -Eeuo pipefail

########################################
# Root Directory
########################################

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

########################################
# Configuration
########################################

ENV_FILE="$ROOT_DIR/.env"

########################################
# Verify Configuration
########################################

if [[ ! -f "$ENV_FILE" ]]; then
    echo
    echo "ERROR: .env file not found."
    echo
    echo "Copy .env.example to .env"
    echo
    exit 1
fi

########################################
# Load Configuration
########################################

set -a
source "$ENV_FILE"
set +a

########################################
# Load Modules
########################################

MODULES=(
    common.sh
    install.sh
    git.sh
    backend.sh
    frontend.sh
    nginx.sh
    systemd.sh
    firewall.sh
    verify.sh
)

for module in "${MODULES[@]}"
do

    MODULE_PATH="$ROOT_DIR/lib/$module"

    if [[ ! -f "$MODULE_PATH" ]]; then
        echo "Missing module:"
        echo "$MODULE_PATH"
        exit 1
    fi

    source "$MODULE_PATH"

done

########################################
# Error Handling
########################################

trap 'deployment_failed $LINENO' ERR

########################################
# Banner
########################################

banner

########################################
# Deployment Summary
########################################

info "Repository      : $GITHUB_REPO"
info "Project         : $PROJECT_NAME"
info "Frontend Folder : $FRONTEND_DIR"
info "Backend Folder  : $BACKEND_DIR"
info "Service         : $SERVICE_NAME"
info "Port            : $PORT"

echo

########################################
# Deployment
########################################

health_check

install_dependencies

clone_repository

deploy_backend

deploy_frontend

configure_nginx

configure_systemd

configure_firewall

verify_deployment

success

exit 0