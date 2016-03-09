#!/bin/bash

function fix-apt-google() {
    if [[ -e /etc/apt/sources.list.d/google-chrome.list ]]; then
        if ! grep "arch=amd64" /etc/apt/sources.list.d/google-chrome.list > /dev/null ; then
            sudo sed -i "s/deb http/deb [arch=amd64] http/" /etc/apt/sources.list.d/google-chrome.list
        fi
    fi
}

function info-message() {
    echo "**** INFO: $@"
}

