#!/bin/bash

set -e

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."

sudo apt-get update && sudo apt-get -y dist-upgrade

install-general-tools
install-vmware-tools

# Install SIFT
if [[ ! -e ~/.config/.sift ]]; then
    wget --quiet -O - https://raw.github.com/sans-dfir/sift-bootstrap/master/bootstrap.sh | sudo bash -s -- -i -s -y
    touch ~/.config/.sift
fi

install-google-chrome

# Clean up
if [[ -e ~/examples.desktop ]]; then
    rm -f ~/examples.desktop
fi
if [[ -e ~/Desktop/SANS-DFIR.pdf ]]; then
    echo "Clean Desktop."
    mkdir ~/Documents/SIFT || true
    mv ~/Desktop/*.pdf ~/Documents/SIFT/ || true
    ln -s ~/Documents/SIFT SIFT || true
fi

# Turn off sound on start up
turn-of-sound

# Info manual config
if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "##################################################################"
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "Run make dotfiles in ~/remnux-tools for .bashrc etc."
    echo "##################################################################"
    touch ~/.config/.manual_conf
fi

