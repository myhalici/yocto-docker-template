#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function info() { echo -e "${GREEN}[INFO]${NC} $1"; }
function warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
function error() { echo -e "${RED}[ERROR]${NC} $1"; }

POKY_DIR="/home/yocto/poky"

# Clone or update poky
if [ ! -d "$POKY_DIR/.git" ]; then
    echo "#########################################################"
    echo " "
    echo "Setting up Yocto Project build environment for Scarthgap"
    echo " "
    echo "#########################################################"
    echo " "
    info "Cloning poky repository..."
    rm -rf "$POKY_DIR"
    git clone git://git.yoctoproject.org/poky "$POKY_DIR"
    cd "$POKY_DIR"
    info "Checking out scarthgap branch..."
    git checkout scarthgap
else
    warn "Poky already exists. Skipping clone."
    cd "$POKY_DIR"
    git fetch origin
    git rebase origin/scarthgap
fi

info "Setting up Yocto build environment to external mounted folders..."
source oe-init-build-env /home/yocto/builds

# change cache settings from local.conf:
# (this step is optional but very useful)

sed -i 's|^DL_DIR ?=.*|DL_DIR ?= "/home/yocto/downloads"|' conf/local.conf
sed -i 's|^SSTATE_DIR ?=.*|SSTATE_DIR ?= "/home/yocto/sstate-cache"|' conf/local.conf

echo " "
info "Now you can start building with like:"
info "    bitbake core-image-minimal"
echo " "

exec /bin/bash

