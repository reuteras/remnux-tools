#!/bin/bash

if [ ! -e ~/remnux-tools/config.cfg ]; then
    echo "Can't find ~/remnux-tools/config.cfg."
    exit 1
fi

# shellcheck disable=SC1090
. ~/remnux-tools/config.cfg

if [[ ! -e ~/shodan/api_key && ! -z "$SHODAN_API_KEY" ]]; then
    echo -n "Initialize Shodan API (access via command shodan): "
    shodan init "$SHODAN_API_KEY"
fi
