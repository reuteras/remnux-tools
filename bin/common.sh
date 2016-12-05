#!/bin/bash

function enable-new-didier() {
    if [[ -d ~/src/git/DidierStevensSuite ]]; then
        chmod 755 ~/src/git/DidierStevensSuite/cut-bytes.py
        chmod 755 ~/src/git/DidierStevensSuite/decoder_*
        chmod 755 ~/src/git/DidierStevensSuite/emldump.py
        chmod 755 ~/src/git/DidierStevensSuite/hex-to-bin.py
        chmod 755 ~/src/git/DidierStevensSuite/oledump.py
        chmod 755 ~/src/git/DidierStevensSuite/pdf-parser.py
        chmod 755 ~/src/git/DidierStevensSuite/pdfid.py
        chmod 755 ~/src/git/DidierStevensSuite/plugin_*
        chmod 755 ~/src/git/DidierStevensSuite/re-search.py
        chmod 755 ~/src/git/DidierStevensSuite/translate.py
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
        ctags \
        curl \
        git \
        exfat-fuse \
        exfat-utils \
        python-virtualenv \
        sharutils \
        tshark \
        vim \
        vim-doc \
        vim-scripts \
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
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i google-chrome-stable_current_amd64.deb || true
        sudo apt-get -f -y install
        rm -f google-chrome-stable_current_amd64.deb
    fi
}
