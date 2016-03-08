#!/bin/bash

set -e

sudo update-remnux
sudo update-sift

sudo apt-get update && sudo apt-get -y dist-upgrade

