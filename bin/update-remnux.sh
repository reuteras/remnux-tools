#!/bin/bash

if [[ -e ~/.config/.sift || -e ~/.config/.moloch ]]; then
    echo "You have installed SIFT or Moloch!"
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

info-message "Remove old versions of Chrome and Wireshark."
# Fixes from https://github.com/sans-dfir/sift/issues/106#issuecomment-251566412
[ -e /etc/apt/sources.list.d/google-chrome.list ] && \
    sudo rm -f /etc/apt/sources.list.d/google-chrome.list*

# Remove old wireshark. Caused errors during update
# shellcheck disable=SC2024
dpkg -l wireshark | grep 1.12 >> $LOG 2>&1 && sudo apt-get -y -qq remove wireshark >> $LOG 2>&1

info-message "Run update-remnux script."
sudo /opt/remnux-scripts/update-remnux

info-message "Update clamav database."
sudo /usr/bin/freshclam || true

update-ubuntu

info-message "Update python colorclass."
# shellcheck disable=SC2024
sudo -H pip install --upgrade colorclass >> $LOG 2>&1

# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Update git repositories
update-git-repositories

# Update python
update-automater
update-chaosreader
update-damm
update-didierstevenssuite
update-floss
update-just-metadata
update-oletools
update-pcodedmp
update-radare2
update-rekall
update-SSMA
update-testssl
update-ViperMonkey
update-volatility-env
update-vt-py
info-message "update-remnux.sh done."
