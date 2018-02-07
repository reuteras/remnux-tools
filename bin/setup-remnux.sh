#!/bin/bash

if [[ -e ~/.config/.sift ]]; then
    echo "You have already installed SIFT! Install Remnux in separate VM."
    exit 1
fi

set -e
LOG=/tmp/remnux-tools.log
touch "$LOG"

# Make a fake sudo to get password before output
sudo touch "$LOG"

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."

info-message "Starting installation of Remnux with remnux-tools."
info-message "Details logged to $LOG."

update-ubuntu

install-general-tools
install-vmware-tools

# https://bugs.launchpad.net/ubuntu/+source/python-pip/+bug/1658844
fix-python-pip

install-remnux
cleanup-remnux

create-common-directories
create-docker-directories
create-cases-not-mounted

install-google-chrome
install-pi-rho-security

# Install pip lib globally
# shellcheck disable=SC2024
sudo -H pip install colorclass >> "$LOG" 2>&1
info-message "Installed python colorclass."

info-message "Setup virtualenvwrapper."
# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

install-automater
install-damm
install-didierstevenssuite
install-floss
install-just-metadata
install-oletools
install-pcodedmp
install-radare2
install-regripper
install-rekall
install-SSMA
install-testssl
install-ViperMonkey
install-volatility-env
#install-volutility
install-vt-py

checkout-git-repo https://github.com/reuteras/resources.git resources
checkout-git-repo https://github.com/Yara-Rules/rules.git yara-rules

turn-of-sound

# Install APT packages for REMnux
install-apt-remnux

# Install aliases
cp ~/remnux-tools/.remnux_aliases ~/.remnux-tools_aliases

# Info manual config
if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "##################################################################"
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "4. Change Desktop Background :)"
    echo "5. Run 'make dotfiles' in ~/remnux-tools for .bashrc etc."
    echo "##################################################################"
    touch ~/.config/.manual_conf
else
    info-message "Update with setup-remnux.sh done."
fi
