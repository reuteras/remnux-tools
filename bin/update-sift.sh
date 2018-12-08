#!/bin/bash

if [[ -e ~/.config/.remnux ]]; then
    echo "You have installed Remnux! Use update-remnux.sh insteed."
    exit 1
fi

set -e

LOG=/tmp/remnux-tools.log
touch $LOG

# Make a fake sudo to get password before output
sudo touch $LOG

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."

info-message "Start update."
info-message "Make sure where not in a virtualenv."
deactivate 2> /dev/null || true

remove-old

info-message "Run update-sift script."
update-sift

info-message "Update clamav database."
sudo /usr/bin/freshclam || info-message "Update of clamav database failed."

update-ubuntu

# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Update git repositories
update-git-repositories

# Update python
update-automater
update-chaosreader
update-dcp
update-floss
update-RecuperaBit
info-message "update-sift.sh done."
