#!/bin/bash

function install_packages {
    sudo apt-get update && sudo apt-get install -y debootstrap 
}

# Execution section

echo "Installing dependencies..."
install_packages
