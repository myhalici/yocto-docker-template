#!/bin/bash
set -e

if [ ! -d "poky" ]; then
    echo "#########################################################"
    echo "Setting up Yocto Project build environment for Scarthgap"
    echo "#########################################################"
    echo " "
    echo "Cloning poky repository..."
    git clone git://git.yoctoproject.org/poky
    cd poky
    echo "Checking out scarthgap branch..."
    git checkout scarthgap
else
    echo "Poky already exists. Skipping clone."
    cd poky
fi

echo "Setting up Yocto build environment to external mounted folders..."
source oe-init-build-env /home/yocto/builds

# change cache settings from local.conf:
# (this step is optional but very useful)

sed -i 's|^DL_DIR ?=.*|DL_DIR ?= "/home/yocto/downloads"|' conf/local.conf
sed -i 's|^SSTATE_DIR ?=.*|SSTATE_DIR ?= "/home/yocto/sstate-cache"|' conf/local.conf

echo " "
echo "Now you can start building with like:"
echo "    bitbake core-image-minimal"
echo " "

exec /bin/bash

