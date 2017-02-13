#!/bin/bash

set -e
LOG=/tmp/remnux-tools.log
touch "$LOG"

# shellcheck source=/dev/null
source ~/remnux-tools/bin/common.sh

if [[ $# == 0 ]]; then
    error-message "Need one argument"
    exit 1
fi

if [[ $1 == "-h" || $1 == "--help" || $1 == "-l" || $1 == "--list" ]]; then
    info-message "Available functions:"
    grep "^function " ~/remnux-tools/bin/common.sh |
        grep -v create-common-directories |
        grep -v enable-new-didier |
        grep -v error-message |
        grep -v info-message |
        grep -v install-apt-remnux |
        grep -v install-general-tools |
        grep -v install-google-chrome |
        grep -v install-pi-rho-security |
        grep -v install-remnux |
        grep -v install-sift |
        grep -v install-vmware-tools |
        grep -v turn-of-sound|
        grep -v update-sift |
        awk '{print $2}' |
        cut -f1 -d\( |
        sort
    exit 0
fi

info-message "Executing function $1."
deactivate 2> /dev/null || true
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh >> $LOG 2>&1
"$@"
info-message "Done."
