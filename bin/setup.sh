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
    mkdir -p ~/cases/docker
fi

for dir in pescanner radare2 mastiff thug v8 viper; do
    if [ ! -d ~/cases/docker/$dir ]; then
        mkdir ~/cases/docker/$dir
        chmod 777 ~/cases/docker/$dir
    fi
done

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
    sudo apt-get -f -y install 
    if ! grep "arch=amd64" /etc/apt/sources.list.d/google-chrome.list > /dev/null ; then 
        sudo sed -i "s/deb http/deb [arch=amd64] http/" /etc/apt/sources.list.d/google-chrome.list
    fi
    rm -f google-chrome-stable_current_amd64.deb
fi

# This repo contians newer versions of Wireshark etc. Update again after adding
if [[ ! -e /etc/apt/sources.list.d/pi-rho-security-trusty.list ]]; then
    sudo add-apt-repository -y ppa:pi-rho/security
    sudo apt-get update && sudo apt-get -y dist-upgrade
    sudo apt-get install html2text nasm && sudo apt-get autoremove -y
fi

# Clean up
if [[ -e ~/examples.desktop ]]; then
    rm -f ~/examples.desktop
fi
if [[ -e ~/Desktop/SANS-DFIR.pdf ]]; then
    mkdir ~/Documents/Remnux_SIFT
    mv ~/Desktop/REMnux* ~/Documents/Remnux_SIFT/
    mv ~/Desktop/*.pdf ~/Documents/Remnux_SIFT/
    rm -f ~/Desktop/cases
fi

# Info manual config
if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "4. Change Desktop Background :)"
    echo "Run make in ~/remnux-tools for .bashrc etc."
    touch ~/.config/.manual_conf
fi

# Add scripts from different sources
# http://phishme.com/powerpoint-and-custom-actions/
[ ! -e ~/src/bin/psparser.py ] && wget -O ~/src/bin/psparser.py \
    https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py && \
    chmod +x ~/src/bin/psparser.py
# https://zeltser.com/convert-shellcode-to-assembly/
[ ! -e ~/src/bin/shellcode2exe.py ] && wget -O ~/src/bin/shellcode2exe.py \
    https://raw.githubusercontent.com/MarioVilas/shellcode_tools/master/shellcode2exe.py && \
    chmod +x ~/src/bin/shellcode2exe.py
