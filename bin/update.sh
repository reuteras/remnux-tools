#!/bin/bash

set -e

sudo update-remnux
sudo update-sift

if ! grep "arch=amd64" /etc/apt/sources.list.d/google-chrome.list > /dev/null ; then
    sudo sed -i "s/deb http/deb [arch=amd64] http/" /etc/apt/sources.list.d/google-chrome.list
fi

sudo apt-get update && sudo apt-get -y dist-upgrade

