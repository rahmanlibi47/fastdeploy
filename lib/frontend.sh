#!/usr/bin/env bash

################################################################################
#
# frontend.sh
#
# Frontend Deployment
#
################################################################################

deploy_frontend() {

    step "Deploying Frontend"

    require_directory "$FRONTEND_PATH"

    cd "$FRONTEND_PATH"

    detect_package_manager

    install_frontend_dependencies

    build_frontend

    publish_frontend

    success_msg "Frontend deployment completed."

}

################################################################################

detect_package_manager() {

    info "Detecting package manager..."

    if [[ -f pnpm-lock.yaml ]]
    then

        PACKAGE_MANAGER="pnpm"

    elif [[ -f yarn.lock ]]
    then

        PACKAGE_MANAGER="yarn"

    else

        PACKAGE_MANAGER="npm"

    fi

    export PACKAGE_MANAGER

    success_msg "$PACKAGE_MANAGER detected."

}

################################################################################

install_frontend_dependencies() {

    step "Installing Frontend Dependencies"

    case "$PACKAGE_MANAGER" in

        npm)

            npm install

        ;;

        yarn)

            if ! command_exists yarn
            then
                npm install -g yarn
            fi

            yarn install

        ;;

        pnpm)

            if ! command_exists pnpm
            then
                npm install -g pnpm
            fi

            pnpm install

        ;;

        *)

            fail "Unknown package manager."

        ;;

    esac

}

################################################################################

build_frontend() {

    step "Building Frontend"

    case "$PACKAGE_MANAGER" in

        npm)

            npm run build

        ;;

        yarn)

            yarn build

        ;;

        pnpm)

            pnpm build

        ;;

    esac

    if [[ ! -d "$BUILD_DIR" ]]
    then
        fail "Build folder '$BUILD_DIR' not found."
    fi

    success_msg "Frontend build successful."

}

################################################################################

publish_frontend() {

    step "Publishing Frontend"

    mkdir -p "$NGINX_ROOT"

    rm -rf "$NGINX_ROOT"/*

    cp -R "$BUILD_DIR"/. "$NGINX_ROOT"

    chown -R www-data:www-data "$NGINX_ROOT"

    chmod -R 755 "$NGINX_ROOT"

    success_msg "Frontend published."

}

################################################################################

print_frontend_information() {

    step "Frontend Information"

    echo

    printf "%-20s %s\n" "Frontend" "$FRONTEND_PATH"

    printf "%-20s %s\n" "Package Manager" "$PACKAGE_MANAGER"

    printf "%-20s %s\n" "Build Folder" "$BUILD_DIR"

    printf "%-20s %s\n" "Publish Path" "$NGINX_ROOT"

    echo

}