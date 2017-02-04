# remnux-tools

This repository contains my scripts to install [REMnux](https://remnux.org) and [Sift](https://github.com/sans-dfir/sift-bootstrap) with some added tools. I started this repository to be able to quickly install a new VM with the tools I use or would like to use more often. This way it is easy to maintain the same images on many computers. To make it even easier to install I've started to test [packer.io](https://www.packer.io/) to automate even more of the process. My repository for this is called [packer](https://github.com/reuteras/packer).

The setup has changed a lot in the beginning of 2017 and it is recommended to install from scratch in a new VM.

There are now two scripts for installs:

* setup-remnux.sh - install [REMnux](https://remnux.org) and tools.
* setup-sift.sh - install [Sift](https://github.com/sans-dfir/sift-bootstrap) and tools.

Earlier the REMnux and Sift distributions where installed together in one VM but due to problems with this I've decided to maintain two scripts. Most of the addons have been moved to the REMnux script. But the separation will make it easier to add new tools in both in the future.

Both scripts starts from a vanilla Ubuntu 14.04 LTS. Personally I start the installation from the [mini.iso](http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/netboot/mini.iso) and I've only tested with the "Ubuntu desktop" installation option.

## setup-remnux.sh

This script install [REMnux](https://remnux.org) and some other tools. Some of the added tools added are now up to date with the regular REMnux install script but is still installed.

The additions are:
* [Ubuntu](https://www.ubuntu.com/) is updated
* Some general packages are installed. This includes bsdgames (some useful tools for CTFs), vim, tshark, exfat and more. Also a basic development environment is installed
* Installs open-vm-tools for VMware
* Create a basic directory structure
* Run the REMnux install script
* Install Google Chrome
* The repository _ppa:pi-rho/security_ is activated and newer versions of many tools are updated from there
* Install some scripts. psparser.py, vt.py, testssl.sh and floss
* Install Tekdefense Automater
* Install DAMM
* Install Volutility
* Install Volatility
* Install Rekall
* Install DidierStevensSuite
* Install oletools
* Install RegRipper2.8
* Install Yara rules
* Install latest [Radare2](https://github.com/radare/radare2)
* Install [tweets_analyzer](https://github.com/x0rz/tweets_analyzer)
* Install my [resources](https://github.com/reuteras/resources) repository
* Turn off sound

If you run *make dotfiles* my version of _.bashrc_, _.vimrc_ are installed. There are a couple of aliases for docker images from REMnux. They use directories under _~/docker/<tool name>_.

## setup-sift.sh

This script installs [Sift](https://github.com/sans-dfir/sift-bootstrap)  and some additional tools listed below:

* [Ubuntu](https://www.ubuntu.com/) is updated
* Some general packages are installed. This includes bsdgames (some useful tools for CTFs), vim, tshark, exfat and more. Also a basic development environment is installed
* Installs open-vm-tools
* Create a basic directory structure
* Run the SIFT install script
* Install Google Chrome
* Install Tekdefense Automater
* Install my [resources](https://github.com/reuteras/resources) repository
* Turn off sound

## Initial setup

First install git and clone the repository. Run all commands as a regular user and use *sudo* when needed.

    sudo apt-get install -y git
    git clone https://github.com/reuteras/remnux-tools.git
    cd remnux-tools

## Install

Choose if you would like to install REMnux or SIFT. Don't try to run both scripts in the same VM since it will not work. To install REMnux with my extra packages listed above:

    ./bin/setup-remux.sh      # or make install

Or to install SIFT with additions listed above:

    ./bin/setup-sift.sh

## Update

To update REMnux and tools run:

    ./bin/update-remnux.sh     # or make update

To update SIFT and tools run:

    ./bin/update-sift.sh

## Clean

This command will clean apt and write zeros to free space. Use this command if you like to shrink your VM size.

    ./bin/clean.sh      # or make clean

If you use VMware remember to run the following command to shrink the image:

    vmware-vdiskmanager -k Virtual\ Disk.vmdk

## Extra utilities

There are some extra utilities in the bin directory.

* **api.sh** - configures api keys from config.cfg. Currently has support for
    - Shodan
    - tweets_analyzer (Twitter API)
* **install-vmhgfs.sh** - Install the vmghfs kernel module.
* **run-one.sh** - Run one function from common. Use **-l** or **--list** for list of functions.
