#!/bin/bash

if [[ -e ~/.config/.sift || -e ~/.config/.arkime ]]; then
    echo "You have installed SIFT or Arkime!"
    exit 1
fi

set -e

LOG=/tmp/remnux-tools.log
touch $LOG

# Make a fake sudo to get password before output
sudo touch $LOG

# shellcheck source=/dev/null
if [[ -e ~/remnux-tools/bin/common.sh ]]; then
    . ~/remnux-tools/bin/common.sh
else
    echo "Cant find common.sh."
    exit 1
fi

info-message "Start update."
info-message "Make sure where not in a virtualenv."
deactivate 2> /dev/null || true

info-message "Remove old versions of Chrome."
# Fixes from https://github.com/sans-dfir/sift/issues/106#issuecomment-251566412
[ -e /etc/apt/sources.list.d/google-chrome.list ] && \
    sudo rm -f /etc/apt/sources.list.d/google-chrome.list*

info-message "Update clamav database."
sudo /usr/bin/freshclam || true

info-message "Run upgrade and update for REMnux."
sudo remnux upgrade && sudo remnux update

update-ubuntu

# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Update git repositories
update-git-repositories

update-brim
update-chaosreader
update-damm
update-just-metadata
update-rekall
update-SSMA
update-testssl
info-message "update-remnux.sh done."
