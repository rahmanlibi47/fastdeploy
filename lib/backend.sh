#!/usr/bin/env bash

################################################################################
#
# backend.sh
#
# Backend Deployment
#
################################################################################

deploy_backend() {

    step "Deploying Backend"

    require_directory "$BACKEND_PATH"

    cd "$BACKEND_PATH"

    create_virtual_environment

    activate_virtual_environment

    install_python_dependencies

    install_gunicorn

    backend_smoke_test

    export BACKEND_WORKDIR="$BACKEND_PATH"

    success_msg "Backend deployment completed."

}

################################################################################

create_virtual_environment() {

    if [[ -d "$VENV_NAME" ]]
    then
        success_msg "Virtual environment already exists."
        return
    fi

    info "Creating virtual environment..."

    python3 -m venv "$VENV_NAME"

    success_msg "Virtual environment created."

}

################################################################################

activate_virtual_environment() {

    info "Activating virtual environment..."

    source "$BACKEND_PATH/$VENV_NAME/bin/activate"

    export PYTHON="$BACKEND_PATH/$VENV_NAME/bin/python"

    export PIP="$BACKEND_PATH/$VENV_NAME/bin/pip"

    export GUNICORN="$BACKEND_PATH/$VENV_NAME/bin/gunicorn"

}

################################################################################

install_python_dependencies() {

    step "Installing Python Dependencies"

    if [[ -f "requirements.txt" ]]
    then

        info "requirements.txt detected."

        "$PIP" install --upgrade pip

        "$PIP" install -r requirements.txt

        return

    fi

    if [[ -f "pyproject.toml" ]]
    then

        info "Poetry project detected."

        if ! command_exists poetry
        then
            info "Installing Poetry..."

            "$PIP" install poetry
        fi

        poetry install

        return

    fi

    fail "No requirements.txt or pyproject.toml found."

}

################################################################################

install_gunicorn() {

    info "Checking Gunicorn..."

    if "$PIP" show gunicorn >/dev/null 2>&1
    then
        success_msg "Gunicorn already installed."
        return
    fi

    info "Installing Gunicorn..."

    "$PIP" install gunicorn

}

################################################################################

backend_smoke_test() {

    step "Backend Smoke Test"

    info "Checking FastAPI module..."

    MODULE=$(echo "$APP_MODULE" | cut -d':' -f1)

    APP=$(echo "$APP_MODULE" | cut -d':' -f2)

    "$PYTHON" -c "
import importlib
m=importlib.import_module('$MODULE')
getattr(m,'$APP')
print('FastAPI import OK')
"

    success_msg "Application import successful."

}

################################################################################

print_backend_information() {

    step "Backend Information"

    echo

    printf "%-20s %s\n" "Backend" "$BACKEND_PATH"

    printf "%-20s %s\n" "Virtualenv" "$VENV_NAME"

    printf "%-20s %s\n" "Python" "$PYTHON"

    printf "%-20s %s\n" "Pip" "$PIP"

    printf "%-20s %s\n" "App Module" "$APP_MODULE"

    printf "%-20s %s\n" "Port" "$PORT"

    echo

}

################################################################################

deactivate_virtual_environment() {

    if command -v deactivate >/dev/null 2>&1
    then
        deactivate
    fi

}