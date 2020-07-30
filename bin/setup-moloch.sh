#!/bin/bash

if [[ -e ~/.config/.remnux ]]; then
    echo "You have already installed Moloch!"
    exit 1
fi

LOG=/tmp/remnux-tools.log
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

info-message "Starting installation of Moloch with remnux-tools."
info-message "Details logged to $LOG."

update-ubuntu

install-general-tools
install-vmware-tools

install-geoip
install-moloch
install-moloch_query
cleanup-moloch

install-suricata

create-common-directories
create-docker-directories
create-cases-not-mounted

install-google-chrome
install-chaosreader

turn-of-sound

# Install aliases for moloch. This way we can update them without
# affecting .bash_aliases.
cp ~/remnux-tools/.moloch_aliases ~/.remnux-tools_aliases

if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "##################################################################"
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "4. Run 'make dotfiles' in ~/remnux-tools for .bashrc etc."
    echo "##################################################################"
    touch ~/.config/.manual_conf
    info-message "Setup with setup-moloch.sh done."
fi
