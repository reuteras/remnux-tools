#!/bin/bash

set -e

sudo update-remnux
sudo update-sift
sudo freshclam

if ! grep "arch=amd64" /etc/apt/sources.list.d/google-chrome.list > /dev/null ; then
    sudo sed -i "s/deb http/deb [arch=amd64] http/" /etc/apt/sources.list.d/google-chrome.list
fi

sudo apt-get update && sudo apt-get -y dist-upgrade

# Update git repositories
cd ~/src/git || exit 1
for repo in *; do
    (cd "$repo" ; git pull)
done

# Update pip
# shellcheck disable=SC1091
cd ~/src/pip/rekall && . bin/activate && echo -n "Update Rekall" && pip install -U rekall && echo " Done."

