#!/bin/bash

if [[ -e ~/.config/.remnux ]]; then
    echo "You have already installed Remnux! Install SIFT in separate VM."
    exit 1
fi

set -e
LOG=/tmp/remnux-tools.log
touch "$LOG"

# Make a fake sudo to get password before output
sudo touch "$LOG"

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."
info-message "Starting installation of SIFT with remnux-tools."
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

# Install SIFT
if [[ ! -e ~/.config/.sift ]]; then
    info-message "Start installation of SIFT."
    wget --quiet -O - https://raw.github.com/sans-dfir/sift-bootstrap/master/bootstrap.sh | sudo bash -s -- -i -s -y
    touch ~/.config/.sift
    info-message "SITF installation finished."
fi

if [ ! -e /cases/not-mounted ]; then
    [[ ! -d /cases ]] && sudo mkdir /cases
    sudo chown "$USER" /cases
    touch /cases/not-mounted
fi

info-message "Install Google Chrome."
install-google-chrome >> "$LOG" 2>&1

info-message "Clean up folders and files."
cleanup-sift >> "$LOG" 2>&1

info-message "Setup virtualenvwrapper."
# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# http://www.tekdefense.com/automater/
install-automater

# https://github.com/reuteras/resources
checkout-git-repo https://github.com/reuteras/resources.git resources

# Turn off sound on start up
turn-of-sound

# Install aliases
cp ~/remnux-tools/.sift_aliases ~/.remnux-tools_aliases

# Info manual config
if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "##################################################################"
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "4. Run 'make dotfiles' in ~/remnux-tools for .bashrc etc."
    echo "##################################################################"
    touch ~/.config/.manual_conf
fi
