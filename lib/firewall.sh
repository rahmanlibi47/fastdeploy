#!/usr/bin/env bash

################################################################################
#
# firewall.sh
#
################################################################################

configure_firewall() {

    step "Firewall Configuration"

    if ! command_exists ufw
    then
        warning "UFW not installed."

        return
    fi

    info "Allowing SSH..."

    ufw allow OpenSSH

    info "Allowing HTTP..."

    ufw allow 80/tcp

    info "Allowing HTTPS..."

    ufw allow 443/tcp

    if ufw status | grep inactive >/dev/null
    then

        info "Enabling UFW..."

        yes | ufw enable

    fi

    success_msg "Firewall configured."

}