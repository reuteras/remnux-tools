#!/bin/bash

set -e

# Fixes from https://github.com/sans-dfir/sift/issues/106#issuecomment-251566412
[ -e /etc/apt/sources.list.d/google-chrome.list ] && \
    rm -f /etc/apt/sources.list.d/google-chrome.list*

# Remove old wireshark. Caused errors during update
dpkg -l wireshark | grep 1.12 && sudo apt-get -y remove wireshark

sudo /opt/remnux-scripts/update-remnux

sudo apt-get remove python-plaso python-pytsk3 mantaray python-dfvfs
sudo apt-get remove pytsk3

sudo /usr/local/bin/update-sift
sudo /usr/bin/freshclam

sudo apt-get update && sudo apt-get -y dist-upgrade

rm -f ~/src/bin/psparser.py ~/src/bin/vt.py ~/src/bin/testssl.sh ~/src/bin/floss

# http://phishme.com/powerpoint-and-custom-actions/
[ ! -e ~/src/bin/psparser.py ] && wget -q -O ~/src/bin/psparser.py \
    https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py && \
    chmod +x ~/src/bin/psparser.py && \
    info-message "Updated psparser.py"
# https://www.virustotal.com/en/documentation/public-api/#getting-file-scans
[ ! -e ~/src/bin/vt.py ] && wget -q -O ~/src/bin/vt.py \
    https://raw.githubusercontent.com/Xen0ph0n/VirusTotal_API_Tool/master/vt.py && \
    chmod +x ~/src/bin/vt.py && \
    info-message "Updated vt.py."
# https://testssl.sh/
[ ! -e ~/src/bin/testssl.sh ] && wget -q -O ~/src/bin/testssl.sh \
    https://testssl.sh/testssl.sh && \
    chmod +x ~/src/bin/testssl.sh && \
    info-message "Updated testssl.sh."
# Fireeye floss
[ ! -e ~/src/bin/floss ] && wget -q -O ~/src/bin/floss \
    https://s3.amazonaws.com/build-artifacts.floss.flare.fireeye.com/travis/linux/dist/floss && \
    chmod +x ~/src/bin/floss && \
    info-message "Updated floss."

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

