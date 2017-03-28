#!/bin/bash

function install_packages {
    sudo apt-get update && sudo apt-get install -y debootstrap libguestfs-tools
}

# Execution section

echo "Installing dependencies..."
install_packages
