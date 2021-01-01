#!/bin/bash

if [[ -e ~/.config/.sift ]]; then
    echo "You have already installed SIFT! Install Remnux in separate VM."
    exit 1
fi

set -e
export LOG=/tmp/remnux-tools.log
touch "$LOG"

# For apt
export DEBIAN_FRONTEND=noninteractive

# Make a fake sudo to get password before output
sudo touch "$LOG"

# shellcheck source=/dev/null
if [[ -e ~/remnux-tools/bin/common.sh ]]; then
    . ~/remnux-tools/bin/common.sh
else
    echo "Cant find common.sh."
    exit 1
fi

info-message "Starting installation of Remnux with remnux-tools."
info-message "Details logged to $LOG."

update-ubuntu

install-general-tools

install-remnux
cleanup-remnux

create-common-directories
create-docker-directories
create-cases-not-mounted

install-google-chrome

info-message "Setup virtualenvwrapper."
# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

install-chaosreader
install-damm
install-just-metadata
install-pcodedmp
install-rekall
install-SSMA
install-testssl

turn-off-sound

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
