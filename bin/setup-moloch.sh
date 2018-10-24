#!/bin/bash

if [[ -e ~/.config/.remnux ]]; then
    echo "You have already installed Moloch!"
    exit 1
fi

set -e
LOG=/tmp/remnux-tools.log
touch "$LOG"

# Make a fake sudo to get password before output
sudo touch "$LOG"

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."

info-message "Starting installation of Moloch with remnux-tools."
info-message "Details logged to $LOG."

update-ubuntu

install-general-tools
install-vmware-tools

install-geoip
install-moloch
install-moloch_query
cleanup-moloch

create-common-directories
create-docker-directories
create-cases-not-mounted

install-google-chrome

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
else
    info-message "Setup with setup-moloch.sh done."
fi
