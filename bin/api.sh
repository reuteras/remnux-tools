#!/bin/bash

if [ ! -e ~/remnux-tools/config.cfg ]; then
    echo "Can't find ~/remnux-tools/config.cfg."
    exit 1
fi

# shellcheck disable=SC1090
. ~/remnux-tools/config.cfg

if [[ ! -e ~/.shodan/api_key && -n "$SHODAN_API_KEY" ]]; then
    if type shodan > /dev/null 2>&1 ; then
        echo -n "Initialize Shodan API (access via command shodan): "
        shodan init "$SHODAN_API_KEY"
    fi
fi

# Configure GIT
if [[ -n $REMNUX_EDITOR ]]; then
    if [[ $(git config --global --get core.editor) != "$REMNUX_EDITOR" ]]; then
        git config --global core.editor "$REMNUX_EDITOR"
    fi
fi

if [[ -n $REMNUX_EMAIL ]]; then
    if [[ $(git config --global --get user.email) != "$REMNUX_EMAIL" ]]; then
        git config --global user.email "$REMNUX_EMAIL"
    fi
fi

if [[ -n $REMNUX_NAME ]]; then
    if [[ $(git config --global --get user.name) != "$REMNUX_NAME" ]]; then
        git config --global user.name "$REMNUX_NAME"
    fi
fi

