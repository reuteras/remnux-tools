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
info-message "Updating Ubuntu."
info-message "Running apt-get update."
# shellcheck disable=SC2024
sudo apt-get -qq update >> "$LOG" 2>&1
info-message "Running apt-get dist-upgrade."
# shellcheck disable=SC2024
sudo apt-get -qq -y dist-upgrade >> "$LOG" 2>&1

info-message "Installing general tools."
install-general-tools >> "$LOG" 2>&1
info-message "Installing tools for VMware."
install-vmware-tools >> "$LOG" 2>&1

info-message "Create directory structure."
if [ ! -d ~/src ]; then
    mkdir -p ~/src/bin
fi

if [ ! -d ~/src/git ]; then
    mkdir -p ~/src/git
fi

if [ ! -d ~/src/python ]; then
    mkdir -p ~/src/python
fi

if [ ! -d ~/docker ]; then
    mkdir -p ~/docker
fi

if [ ! -d /cases ]; then
    sudo mkdir /cases
    sudo chown "$USER" /cases
    touch /cases/not-mounted
fi

for dir in pescanner radare2 mastiff thug v8 viper; do
    if [ ! -d ~/docker/$dir ]; then
        mkdir ~/docker/$dir
        chmod 777 ~/docker/$dir
    fi
done

# Install Remnux
if [[ ! -e ~/.config/.remnux ]]; then
    info-message "Start installation of Remnux."
    wget --quiet -O - https://remnux.org/get-remnux.sh | sudo bash
    touch ~/.config/.remnux
    info-message "Remnux installation finished."
fi

info-message "Install Google Chrome."
install-google-chrome >> "$LOG" 2>&1

info-message "Enable ppa:pi-rho/security and install updated packages."
install-pi-rho-security >> "$LOG" 2>&1

info-message "Clean up folders and files."
cleanup-remnux >> "$LOG" 2>&1

install-single-file-scripts

# Install pip lib globally
# shellcheck disable=SC2024
sudo -H pip install colorclass >> "$LOG" 2>&1
info-message "Installed python colorclass."

info-message "Setup virtualenvwrapper."
# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# http://www.tekdefense.com/automater/
install-automater

# https://n0where.net/malware-analysis-damm/
install-damm

# Install Volutility
install-volutility

# Keep a seperate environment for volatility (to be able to upgrade separatly)
install-volatility-env

# https://github.com/DidierStevens/DidierStevensSuite
install-didierstevenssuite

# https://github.com/decalage2/oletools.git
install-oletools

# Rekall
install-rekall

# Other tools
# https://github.com/keydet89/RegRipper2.8
install-regripper

# https://github.com/Yara-Rules/rules
checkout-git-repo https://github.com/Yara-Rules/rules.git yara-rules

# https://github.com/reuteras/resources
checkout-git-repo https://github.com/reuteras/resources.git resources

# https://github.com/radare/radare2
install-radare2

# Turn off sound on start up
turn-of-sound

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
fi
