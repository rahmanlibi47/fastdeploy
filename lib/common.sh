#!/usr/bin/env bash

################################################################################
#
# Common Utility Functions
#
################################################################################

########################################
# Colors
########################################

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
NC="\033[0m"

########################################
# Banner
########################################

banner() {

clear

echo -e "${CYAN}"
echo "========================================================"
echo "                 FAST DEPLOY"
echo "========================================================"
echo -e "${NC}"

}

########################################
# Logging
########################################

info() {

echo -e "${BLUE}[INFO]${NC} $1"

}

success_msg() {

echo -e "${GREEN}[SUCCESS]${NC} $1"

}

warning() {

echo -e "${YELLOW}[WARNING]${NC} $1"

}

error() {

echo -e "${RED}[ERROR]${NC} $1"

}

########################################
# Exit Helpers
########################################

fail() {

error "$1"

exit 1

}

########################################
# Deployment Finished
########################################

success() {

echo

echo -e "${GREEN}"
echo "========================================================"
echo "             DEPLOYMENT COMPLETED"
echo "========================================================"
echo -e "${NC}"

}

########################################
# Deployment Failed
########################################

deployment_failed() {

LINE="$1"

echo

echo -e "${RED}"
echo "========================================================"
echo "              DEPLOYMENT FAILED"
echo "========================================================"
echo -e "${NC}"

echo

echo "Failure near line $LINE"

echo

exit 1

}

########################################
# Command Exists
########################################

command_exists() {

command -v "$1" >/dev/null 2>&1

}

########################################
# Require Root
########################################

require_root() {

if [[ "$EUID" -ne 0 ]]
then
    fail "Run using sudo."
fi

}

########################################
# Internet Check
########################################

internet_check() {

info "Checking internet..."

if ping -c 1 github.com >/dev/null 2>&1
then
    success_msg "Internet available."
else
    fail "No internet connection."
fi

}

########################################
# Health Check
########################################

health_check() {

require_root

internet_check

}

########################################
# File Exists
########################################

require_file() {

FILE="$1"

if [[ ! -f "$FILE" ]]
then
    fail "Missing file: $FILE"
fi

}

########################################
# Directory Exists
########################################

require_directory() {

DIR="$1"

if [[ ! -d "$DIR" ]]
then
    fail "Missing directory: $DIR"
fi

}

########################################
# Find Directory
########################################

find_directory() {

NAME="$1"

find . -type d -name "$NAME" | head -n 1

}

########################################
# Spinner
########################################

spinner() {

PID=$!

SP="/-\|"

while ps -p $PID > /dev/null
do
    printf "\r[%c] Working..." "${SP:i++%${#SP}:1}"
    sleep .1
done

printf "\r"

}

########################################
# Separator
########################################

line() {

echo "--------------------------------------------------------"

}

########################################
# Print Step
########################################

step() {

line

echo -e "${PURPLE}$1${NC}"

line

}

########################################
# Pause
########################################

pause() {

read -p "Press Enter to continue..."

}