#!/bin/bash

sudo systemctl start elasticsearch.service
while true; do
    # Make sure Elasticsearch is up
    STATUS=$(curl -s http://localhost:9200/dstats/version/version/_source)
    if [[ -n $STATUS ]]; then
        break
    fi
done
INTERFACE=$(ip addr | grep "state UP" | awk '{print $2}' | tr -d ":")
sudo sed -i -e "s/interface: eth0/interface: ${INTERFACE}/" /etc/suricata/suricata.yaml
sudo suricata-update update-sources > /dev/null 2>&1
sudo sudo suricata-update > /dev/null 2>&1
sudo systemctl start suricata.service
sudo systemctl start arkimecapture.service
sudo systemctl start arkimeviewer.service
/opt/google/chrome/chrome http://127.0.0.1:8005 > /dev/null 2>&1 &
