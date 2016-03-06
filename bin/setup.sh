#!/bin/bash

set -e

sudo apt-get update && sudo apt-get -y dist-upgrade

# General tools
sudo apt-get -y -qq install ctags curl git vim vim-doc vim-scripts \
    exfat-fuse exfat-utils zip

# Tools for Vmware
sudo apt-get -y -qq install open-vm-tools-desktop fuse

if [ ! -d ~/src ]; then
    mkdir -p ~/src/bin
fi    

if [ ! -d ~/cases ]; then
    mkdir ~/cases
fi    

# Install Remnux
if [[ ! -e ~/.config/.remnux ]]; then
    wget --quiet -O - https://remnux.org/get-remnux.sh | sudo bash
    touch ~/.config/.remnux
fi

# Install Sift
if [[ ! -e ~/.config/.sift ]]; then
    wget --quiet -O - https://raw.github.com/sans-dfir/sift-bootstrap/master/bootstrap.sh | sudo bash -s -- -i -s -y
    touch ~/.config/.sift
fi

# Install Chrome
if ! dpkg --status google-chrome-stable > /dev/null 2>&1 ; then
    cd /tmp
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb || true
    sudo apt-get -f install
    rm -f google-chrome-stable_current_amd64.deb
fi

# This repo contians newer versions of Wireshark etc. Update again after adding
if ! grep phi-rho/security /etc/apt/sources.list > /dev/null ; then
    sudo add-apt-repository ppa:pi-rho/security
    sudo apt-get update && sudo apt-get -y dist-upgrade
fi

