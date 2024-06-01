#!/bin/bash

URLS="https://www.malware-traffic-analysis.net/2022/03/21/2022-03-21-traffic-analysis-exercise.pcap.zip \
    https://www.malware-traffic-analysis.net/2022/02/23/2022-02-23-traffic-analysis-exercise.pcap.zip \
    https://www.malware-traffic-analysis.net/2022/01/07/2022-01-07-traffic-analysis-exercise.pcap.zip \
    https://www.malware-traffic-analysis.net/2021/12/08/2021-12-ISC-Forensic-Challenge.pcap.zip \
    https://www.malware-traffic-analysis.net/2021/10/22/2021-10-22-ISC-forensic-challenge-traffic.pcap.zip \
    https://www.malware-traffic-analysis.net/2021/09/10/2021-09-10-traffic-analysis-exercise.pcap.zip \
    https://www.malware-traffic-analysis.net/2021/08/19/2021-08-19-traffic-analysis-exercise.pcap.zip \
    https://www.malware-traffic-analysis.net/2021/07/14/2021-07-traffic-analysis-exercise.pcap.zip \
    https://www.malware-traffic-analysis.net/2021/02/08/2021-02-08-traffic-analysis-exercise.pcap.zip \
    https://www.malware-traffic-analysis.net/2021/01/21/2021-01-21-traffic-analysis-exercise.pcap.zip"

cd ~/Downloads || exit

echo "Download sample pcap files from https://www.malware-traffic-analysis.net/ and save them in ~/Downloads."
for url in ${URLS} ; do
    echo "Download ${url}"
    wget "${url}" > /dev/null 2>&1
done

for file in *.pcap.zip ; do
    number=$(echo "${file}" | cut -f1,2,3 -d- | tr -d '-')
    password="infected_${number}"
    echo "Unzip ${file} with password ${password}"
    unzip -P "${password}" "${file}" > /dev/null 2>&1
    rm "${file}"
 done
    
