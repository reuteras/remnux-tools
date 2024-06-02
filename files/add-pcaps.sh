#!/bin/bash

for location in "${@}"; do
    if [[ -e "${location}" ]]; then
        find "${location}" -type f -print0 | while read -r -d $'\0' pcap; do
            sudo suricata -c /etc/suricata/suricata.yaml -r "${pcap}" -l /var/log/suricata
            : "${TAG:=--tag import}"
            # shellcheck disable=SC2086
            sudo /opt/arkime/bin/capture --flush -r "${pcap}" --copy $TAG
        done
    fi
done
