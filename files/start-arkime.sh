#!/bin/bash

sudo systemctl start elasticsearch.service
while true; do
    # Make sure Elasticsearch is up
    STATUS=$(curl -s http://localhost:9200/dstats/version/version/_source)
    if [[ -n $STATUS ]]; then
        break
    fi
done
sudo systemctl start molochcapture.service
sudo systemctl start molochviewer.service
/opt/google/chrome/chrome http://127.0.0.1:8005 > /dev/null 2>&1 &
