#!/bin/bash

sudo apt-get -y autoremove
sudo apt-get autoclean
sudo apt-get clean
rm -f /tmp/remnux-tools.log

dd if=/dev/zero of="$HOME/zero" conv=fsync
sleep 1
sync
rm -f "$HOME"/zero
