#!/bin/bash

set -e

sudo /opt/remnux-scripts/update-remnux
sudo /usr/local/bin/update-sift
sudo /usr/bin/freshclam

sudo apt-get update && sudo apt-get -y dist-upgrade

# Update git repositories
cd ~/src/git || exit 1
for repo in *; do
    (cd "$repo"; git fetch --all; git reset --hard origin/master)
done

# Update pip
# shellcheck disable=SC1091
cd ~/src/pip/rekall && . bin/activate && \
    echo "Update pip and setuptools before updating Rekall." && \
    pip install -U pip setuptools && \
    echo -n "Update Rekall" && \
    pip install -U rekall && \
    echo " Done."

