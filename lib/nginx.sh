#!/usr/bin/env bash

################################################################################
#
# nginx.sh
#
# Configure Nginx
#
################################################################################

configure_nginx() {

    step "Configuring Nginx"

    create_nginx_config

    enable_nginx_site

    test_nginx

    restart_nginx

    success_msg "Nginx configured."

}

################################################################################

create_nginx_config() {

    info "Creating nginx configuration..."

    cat > "/etc/nginx/sites-available/$PROJECT_NAME" <<EOF
server {

    listen 80;

    server_name $DOMAIN;

    root $NGINX_ROOT;

    index index.html;

    client_max_body_size 100M;

    ####################################################
    # Frontend
    ####################################################

    location / {

        try_files \$uri \$uri/ /index.html;

    }

    ####################################################
    # FastAPI
    ####################################################

    location /api/ {

        proxy_pass http://127.0.0.1:$PORT/;

        proxy_http_version 1.1;

        proxy_set_header Host \$host;

        proxy_set_header X-Real-IP \$remote_addr;

        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_set_header Upgrade \$http_upgrade;

        proxy_set_header Connection "upgrade";

    }

}
EOF

    success_msg "Nginx configuration created."

}

################################################################################

enable_nginx_site() {

    info "Enabling site..."

    ln -sf \
    "/etc/nginx/sites-available/$PROJECT_NAME" \
    "/etc/nginx/sites-enabled/$PROJECT_NAME"

    rm -f /etc/nginx/sites-enabled/default

}

################################################################################

test_nginx() {

    info "Testing nginx configuration..."

    nginx -t

}

################################################################################

restart_nginx() {

    info "Restarting nginx..."

    systemctl enable nginx

    systemctl restart nginx

}

################################################################################

print_nginx_information() {

    step "Nginx"

    echo

    printf "%-20s %s\n" "Domain" "$DOMAIN"

    printf "%-20s %s\n" "Frontend" "$NGINX_ROOT"

    printf "%-20s %s\n" "Backend" "127.0.0.1:$PORT"

    printf "%-20s %s\n" "Site" "/etc/nginx/sites-available/$PROJECT_NAME"

    echo

}

################################################################################

remove_nginx() {

    rm -f "/etc/nginx/sites-enabled/$PROJECT_NAME"

    rm -f "/etc/nginx/sites-available/$PROJECT_NAME"

    systemctl restart nginx

}