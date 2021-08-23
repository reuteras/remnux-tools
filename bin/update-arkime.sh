#!/bin/bash

if [[ -e ~/.config/.remnux || -e ~/.config/.sift ]]; then
    echo "You have installed Remnux or Sift!"
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

remove-old

info-message "Run update-arkime script."
update-chaosreader
update-arkime
update-geoip
update-ubuntu

info-message "update-sift.sh done."
