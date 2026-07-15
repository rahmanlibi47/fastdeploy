#!/usr/bin/env bash

################################################################################
#
# git.sh
#
# Repository Management
#
################################################################################

clone_repository() {

    step "Repository Setup"

    require_variable GITHUB_REPO
    require_variable PROJECT_NAME

    PROJECT_PATH="/home/$SUDO_USER/$PROJECT_NAME"

    export PROJECT_PATH

    if [[ -d "$PROJECT_PATH/.git" ]]
    then

        info "Repository already exists."

        update_repository

    else

        clone_repo

    fi

    detect_project_structure

}

################################################################################

clone_repo() {

    info "Cloning repository..."

    git clone "$GITHUB_REPO" "$PROJECT_PATH"

    success_msg "Repository cloned."

}

################################################################################

update_repository() {

    info "Updating repository..."

    cd "$PROJECT_PATH"

    git fetch --all

    if [[ -n "${GIT_BRANCH:-}" ]]
    then

        git checkout "$GIT_BRANCH"

    fi

    git pull

    success_msg "Repository updated."

}

################################################################################

detect_project_structure() {

    step "Detecting Project Structure"

    cd "$PROJECT_PATH"

    FRONTEND_PATH="$PROJECT_PATH/$FRONTEND_DIR"

    BACKEND_PATH="$PROJECT_PATH/$BACKEND_DIR"

    if [[ ! -d "$FRONTEND_PATH" ]]
    then
        fail "Frontend folder not found."

    fi

    if [[ ! -d "$BACKEND_PATH" ]]
    then
        fail "Backend folder not found."

    fi

    export FRONTEND_PATH
    export BACKEND_PATH

    success_msg "Frontend : $FRONTEND_PATH"

    success_msg "Backend  : $BACKEND_PATH"

}

################################################################################

require_variable() {

    VAR="$1"

    VALUE="${!VAR}"

    if [[ -z "$VALUE" ]]
    then
        fail "$VAR not configured in .env"
    fi

}

################################################################################

current_commit() {

    cd "$PROJECT_PATH"

    git rev-parse --short HEAD

}

################################################################################

print_git_information() {

    step "Repository Information"

    cd "$PROJECT_PATH"

    echo

    printf "%-20s %s\n" "Repository" "$GITHUB_REPO"

    printf "%-20s %s\n" "Project" "$PROJECT_NAME"

    printf "%-20s %s\n" "Branch" "$(git branch --show-current)"

    printf "%-20s %s\n" "Commit" "$(current_commit)"

    echo

}

################################################################################

checkout_branch() {

    if [[ -z "${GIT_BRANCH:-}" ]]
    then
        return
    fi

    cd "$PROJECT_PATH"

    git checkout "$GIT_BRANCH"

}

################################################################################

repository_exists() {

    [[ -d "$PROJECT_PATH/.git" ]]

}

################################################################################

pull_latest() {

    cd "$PROJECT_PATH"

    git pull

}