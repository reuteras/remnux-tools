#!/bin/bash

if [[ -e ~/.config/.sift ]]; then
    echo "You have installed SIFT! Use update-sift.sh insteed."
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
sudo /usr/bin/freshclam

info-message "Update Ubuntu."
# shellcheck disable=SC2024
sudo apt-get -qq update >> $LOG 2>&1
# shellcheck disable=SC2024
sudo apt-get -y -qq dist-upgrade >> $LOG 2>&1

update-psparser
update-vt-py
update-testssl
update-floss

info-message "Update python colorclass."
# shellcheck disable=SC2024
sudo -H pip install --upgrade colorclass >> $LOG 2>&1

# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Update git repositories
cd ~/src/git || exit 1
info-message "Update git repositories."
for repo in *; do
    info-message "Updating $repo."
    (cd "$repo"; git fetch --all >> "$LOG" 2>&1; git reset --hard origin/master >> $LOG 2>&1)
done

# Update python
update-automater
update-damm
update-volutility
update-volatility-env
update-didierstevenssuite
update-oletools
update-rekall
update-radare2
update-pcodedmp
update-just-metadata
info-message "Update done."
