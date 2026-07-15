#!/usr/bin/env bash

################################################################################
#
# systemd.sh
#
# Creates and manages FastAPI systemd service
#
################################################################################

configure_systemd() {

    step "Configuring systemd Service"

    create_service

    reload_systemd

    enable_service

    start_service

    verify_service

}

################################################################################

create_service() {

    info "Creating systemd service..."

    cat > /etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=$PROJECT_NAME FastAPI Backend
After=network.target

[Service]

User=root
Group=root

WorkingDirectory=$BACKEND_PATH

Environment="PATH=$BACKEND_PATH/$VENV_NAME/bin"

ExecStart=$BACKEND_PATH/$VENV_NAME/bin/gunicorn \
    -k uvicorn.workers.UvicornWorker \
    -w 2 \
    -b 0.0.0.0:$PORT \
    $APP_MODULE

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    success_msg "Service created."

}

################################################################################

reload_systemd() {

    info "Reloading systemd..."

    systemctl daemon-reload

}

################################################################################

enable_service() {

    info "Enabling service..."

    systemctl enable "$SERVICE_NAME"

}

################################################################################

start_service() {

    info "Starting service..."

    systemctl restart "$SERVICE_NAME"

}

################################################################################

verify_service() {

    info "Checking service..."

    sleep 3

    if systemctl is-active --quiet "$SERVICE_NAME"
    then

        success_msg "Service running."

    else

        error "Service failed."

        echo

        journalctl -u "$SERVICE_NAME" --no-pager -n 50

        exit 1

    fi

}

################################################################################

restart_backend() {

    info "Restarting backend..."

    systemctl restart "$SERVICE_NAME"

}

################################################################################

stop_backend() {

    info "Stopping backend..."

    systemctl stop "$SERVICE_NAME"

}

################################################################################

service_status() {

    systemctl status "$SERVICE_NAME"

}

################################################################################

show_logs() {

    journalctl -u "$SERVICE_NAME" -f

}

################################################################################

print_service_information() {

    step "Backend Service"

    echo

    printf "%-20s %s\n" "Service" "$SERVICE_NAME"

    printf "%-20s %s\n" "Working Dir" "$BACKEND_PATH"

    printf "%-20s %s\n" "App Module" "$APP_MODULE"

    printf "%-20s %s\n" "Port" "$PORT"

    echo

}

################################################################################

remove_service() {

    info "Removing service..."

    systemctl stop "$SERVICE_NAME" || true

    systemctl disable "$SERVICE_NAME" || true

    rm -f "/etc/systemd/system/$SERVICE_NAME.service"

    systemctl daemon-reload

}