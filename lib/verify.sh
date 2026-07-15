#!/usr/bin/env bash

################################################################################
#
# verify.sh
#
# Verifies deployment
#
################################################################################

verify_deployment() {

    step "Deployment Verification"

    verify_backend_service

    verify_backend_endpoint

    verify_nginx

    verify_frontend

    print_summary

}

################################################################################

verify_backend_service() {

    info "Checking backend service..."

    if systemctl is-active --quiet "$SERVICE_NAME"
    then
        success_msg "Backend service is running."
    else
        fail "Backend service is not running."
    fi

}

################################################################################

verify_backend_endpoint() {

    info "Checking FastAPI..."

    sleep 2

    STATUS=$(curl \
        -o /dev/null \
        -s \
        -w "%{http_code}" \
        http://127.0.0.1:$PORT/docs)

    if [[ "$STATUS" == "200" ]]
    then
        success_msg "FastAPI responding."
    else
        fail "FastAPI returned HTTP $STATUS"
    fi

}

################################################################################

verify_nginx() {

    info "Checking nginx..."

    if systemctl is-active --quiet nginx
    then
        success_msg "Nginx is running."
    else
        fail "Nginx is not running."
    fi

}

################################################################################

verify_frontend() {

    info "Checking frontend..."

    if [[ ! -f "$NGINX_ROOT/index.html" ]]
    then
        fail "Frontend index.html missing."
    fi

    STATUS=$(curl \
        -o /dev/null \
        -s \
        -w "%{http_code}" \
        http://127.0.0.1)

    if [[ "$STATUS" == "200" ]]
    then
        success_msg "Frontend responding."
    else
        fail "Frontend returned HTTP $STATUS"
    fi

}

################################################################################

print_summary() {

    step "Deployment Summary"

    echo

    printf "%-22s %s\n" "Project" "$PROJECT_NAME"

    printf "%-22s %s\n" "Repository" "$GITHUB_REPO"

    printf "%-22s %s\n" "Frontend" "$FRONTEND_PATH"

    printf "%-22s %s\n" "Backend" "$BACKEND_PATH"

    printf "%-22s %s\n" "Service" "$SERVICE_NAME"

    printf "%-22s %s\n" "Backend Port" "$PORT"

    printf "%-22s %s\n" "Frontend Root" "$NGINX_ROOT"

    printf "%-22s %s\n" "Domain" "$DOMAIN"

    echo

    echo "----------------------------------------------------------"

    echo

    echo "Frontend"

    echo "http://$DOMAIN"

    echo

    echo "Swagger"

    echo "http://$DOMAIN/api/docs"

    echo

    echo "Backend Local"

    echo "http://127.0.0.1:$PORT/docs"

    echo

}

################################################################################

restart_everything() {

    info "Restarting services..."

    systemctl restart "$SERVICE_NAME"

    systemctl restart nginx

}

################################################################################

show_status() {

    echo

    systemctl --no-pager status "$SERVICE_NAME"

    echo

    systemctl --no-pager status nginx

}

################################################################################

show_logs() {

    echo

    journalctl -u "$SERVICE_NAME" --no-pager -n 50

}