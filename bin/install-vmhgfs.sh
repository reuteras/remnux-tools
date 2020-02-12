#!/bin/bash

set -e
LOG=/tmp/remnux-tools.log
touch "$LOG"

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."

if [[ -f "$1" ]]; then
    LINUX_ISO="$1"
else
    LINUX_ISO="$HOME/Desktop/linux.iso"
fi

if [[ ! -f "$LINUX_ISO" ]]; then
    info-message "You have to copy linux.iso from your VMware installation to ~/Desktop/linux.iso or pass the pass as the first argument."
    info-message "On Macos open /Applications and right click on VMware Fusion. You'll find the linux.iso under Contents/Library/isoimages."
    exit 1
fi

info-message "Starting installation of VMware vmhgfs module with remnux-tools."
info-message "Details logged to $LOG."

TMP_DIR=$(mktemp -d)
CURRENT_DIR=$PWD
info-message "Created TMP_DIR: $TMP_DIR"

info-message "Mount linux.iso"
[[ ! -d /mnt/cdrom ]] && sudo mkdir -p /mnt/cdrom
sudo mount --read-only "$LINUX_ISO" /mnt/cdrom
cd "$TMP_DIR" || exit "Couldn't cd to $TMP_DIR"
info-message "Extract VMwareTools."
tar zxf /mnt/cdrom/VMwareTools*.tar.gz
info-message "Umount linux.iso"
sudo umount /mnt/cdrom
cd vmware-tools-distrib || exit "Couldn't cd to vmware-tools-distrib."

info-message "Start vmware-install.pl."
# shellcheck disable=SC2024
sudo ./vmware-install.pl -d >> "$LOG" 2>&1
info-message "Installation completed."

info-message "Remove TMP_DIR: $TMP_DIR"
cd "$CURRENT_DIR"
rm -rf "$TMP_DIR"

if [[ "$(vmware-hgfsclient)" != "" ]]; then
    info-message "Run the following command to mount your share on /cases:"
    info-message "sudo mount -t vmhgfs .host:/$(vmware-hgfsclient) /cases"
fi

info-message "Stopping open-vm-tools."
# shellcheck disable=SC2024
sudo service open-vm-tools stop >> "$LOG" 2>&1
info-message "Starting open-vm-tools."
# shellcheck disable=SC2024
sudo service open-vm-tools stop >> "$LOG" 2>&1
info-message "You still might need to reboot to get copy and paste to work."
info-message "Installation of vmhgfs completed."
