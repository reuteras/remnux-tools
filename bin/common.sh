#!/bin/bash

function enable-new-didier() {
    if [[ -d ~/src/python/didierstevenssuite ]]; then
        chmod 755 ~/src/python/didierstevenssuite/cut-bytes.py
        chmod 755 ~/src/python/didierstevenssuite/decoder_*
        chmod 755 ~/src/python/didierstevenssuite/emldump.py
        chmod 755 ~/src/python/didierstevenssuite/hex-to-bin.py
        chmod 755 ~/src/python/didierstevenssuite/oledump.py
        chmod 755 ~/src/python/didierstevenssuite/pdf-parser.py
        chmod 755 ~/src/python/didierstevenssuite/pdfid.py
        chmod 755 ~/src/python/didierstevenssuite/plugin_*
        chmod 755 ~/src/python/didierstevenssuite/re-search.py
        chmod 755 ~/src/python/didierstevenssuite/translate.py
    fi
}

function info-message() {
    echo "**** INFO: $*"
}

# Turn off sound on start up
function turn-of-sound() {
    [ ! -e /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override ] && \
        echo -e '[com.canonical.unity-greeter]\nplay-ready-sound = false' | \
        sudo tee -a /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override > /dev/null && \
        sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
}

# General tools
function install-general-tools() {
    sudo apt-get -y -qq install \
        bsdgames \
        build-essential \
        ctags \
        curl \
        git \
        exfat-fuse \
        exfat-utils \
        libffi-dev \
        libimage-exiftool-perl \
        libssl-dev \
        python-dev \
        python-virtualenv \
        sharutils \
        tshark \
        vim \
        vim-doc \
        vim-scripts \
        virtualenvwrapper \
        whois \
        wswedish \
        zip
}

# Tools for Vmware
function install-vmware-tools() {
    sudo apt-get -y -qq install \
        fuse \
        open-vm-tools-desktop
}

# Install Google Chrome
function install-google-chrome() {
    if ! dpkg --status google-chrome-stable > /dev/null 2>&1 ; then
        cd /tmp || exit 0
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /dev/null
        sudo dpkg -i google-chrome-stable_current_amd64.deb || true
        sudo apt-get -qq -f -y install
        rm -f google-chrome-stable_current_amd64.deb
    fi
}

# Install Volatility
# First argument should be target path to check out volatility.
function install-volatility() {
    if [ $# -eq 0 ]; then
        echo "One argument expected for install-volatility()"
        exit 1
    fi
    if [ -d "$1" ]; then
        echo "$1 already exists!"
        exit 1
    fi
    git clone --quiet https://github.com/volatilityfoundation/volatility \
        "$1" && \
    cd "$1" && \
    pip install \
        Pillow \
        distorm3 \
        openpyxl \
        pycrypto \
        ujson \
        yara-python && \
        python setup.py install
}

# This repo contians newer versions of Wireshark etc. Update again after adding
function install-pi-rho-security(){
    if [[ ! -e /etc/apt/sources.list.d/pi-rho-security-trusty.list ]]; then
        sudo add-apt-repository -y ppa:pi-rho/security
        sudo apt-get -qq update && sudo apt-get -qq -y dist-upgrade
        sudo apt-get -qq -y install html2text nasm && sudo apt-get autoremove -qq -y
    fi
}

# Cleanup function
function cleanup(){
   if [[ -e ~/examples.desktop ]]; then
        rm -f ~/examples.desktop
    fi
    if [[ -e ~/Desktop/SANS-DFIR.pdf ]]; then
        echo "Clean Desktop."
        mkdir ~/Documents/Remnux_SIFT
        mv ~/Desktop/REMnux* ~/Documents/Remnux_SIFT/
        mv ~/Desktop/*.pdf ~/Documents/Remnux_SIFT/
        rm -f ~/Desktop/cases
    fi
}
