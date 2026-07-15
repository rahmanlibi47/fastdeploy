#!/usr/bin/env bash

################################################################################
#
# install.sh
#
# Installs all system dependencies required for deployment.
#
################################################################################

install_dependencies() {

    step "Installing System Dependencies"

    export DEBIAN_FRONTEND=noninteractive

    info "Updating package list..."

    apt-get update -y

    info "Installing base packages..."

    install_package git git
    install_package curl curl
    install_package wget wget
    install_package unzip unzip
    install_package nginx nginx
    install_package python3 python3
    install_package pip3 python3-pip
    install_package python3-venv python3-venv
    install_package gcc build-essential
    install_package make build-essential

    install_node

    verify_installation

}

################################################################################

install_package() {

    local COMMAND=$1
    local PACKAGE=$2

    if command_exists "$COMMAND"
    then
        success_msg "$PACKAGE already installed."
        return
    fi

    info "Installing $PACKAGE..."

    apt-get install -y "$PACKAGE"

}

################################################################################

install_node() {

    if command_exists node
    then

        success_msg "NodeJS already installed."

        node -v

        npm -v

        return

    fi

    info "Installing NodeJS..."

    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash -

    apt-get install -y nodejs

    success_msg "NodeJS Installed."

    node -v

    npm -v

}

################################################################################

verify_installation() {

    step "Installed Versions"

    echo

    printf "%-20s %s\n" "Git" "$(git --version)"

    printf "%-20s %s\n" "Python" "$(python3 --version)"

    printf "%-20s %s\n" "Pip" "$(pip3 --version | cut -d' ' -f1-2)"

    printf "%-20s %s\n" "Node" "$(node -v)"

    printf "%-20s %s\n" "NPM" "$(npm -v)"

    printf "%-20s %s\n" "Nginx" "$(nginx -v 2>&1)"

    echo

}

################################################################################

upgrade_system() {

    info "Running apt upgrade..."

    apt-get upgrade -y

}

################################################################################

clean_system() {

    info "Cleaning unused packages..."

    apt-get autoremove -y

    apt-get autoclean -y

}

################################################################################

bootstrap() {

    upgrade_system

    install_dependencies

    clean_system

}