#!/bin/bash

sudo apt-get autoremove && sudo apt-get autoclean && \
    sudo apt-get clean

dd if=/dev/zero of="$HOME/zero" conv=fsync; sleep 1 ; sync; rm -f "$HOME"/zero

