#!/bin/bash

if [[ -e ~/.config/.remnux ]]; then
    echo "You have already installed Remnux! Install SIFT in separate VM."
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

info-message "Starting installation of SIFT with remnux-tools."
info-message "Details logged to $LOG."

update-ubuntu

install-general-tools
install-vmware-tools

install-sift
cleanup-sift

create-common-directories
create-docker-directories
create-cases-not-mounted

install-google-chrome

info-message "Setup virtualenvwrapper."
# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

install-automater
install-chaosreader
install-dcp
install-floss
install-RecuperaBit

turn-off-sound

# Install aliases for sift. This way we can update them without
# affecting .bash_aliases.
cp ~/remnux-tools/.sift_aliases ~/.remnux-tools_aliases

if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "##################################################################"
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "4. Run 'make dotfiles' in ~/remnux-tools for .bashrc etc."
    echo "##################################################################"
    touch ~/.config/.manual_conf
else
    info-message "Update with setup-sift.sh done."
fi
