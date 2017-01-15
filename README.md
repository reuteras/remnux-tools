# remnux-tools

This repository contains my scripts to install [Remnux](https://remnux.org) and [Sift](https://github.com/sans-dfir/sift-bootstrap) with some added tools. I started this repository to be able to quickly install a new VM with the tools I use or would like to use more often. This way it is easy to maintain the same images on many computers.

The setup has changed a lot in the beginning of 2017 and it is recommended to install from scratch in a new VM.

There are now two scripts for installs:

* setup-remnux.sh - install [Remnux](https://remnux.org) and tools.
* setup-sift.sh - install [Sift](https://github.com/sans-dfir/sift-bootstrap) and tools.

Earlier the Remnux and Sift distributions where installed together in one VM but due to problems with this I've decided to maintain two scripts. Most of the addons have been moved to the Remnux script. But the separation will make it easier to add new tools in both in the future. 

Both scripts starts from a vanilla Ubuntu 14.04 LTS. Personally I start the installation from the [mini.iso](http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/netboot/mini.iso) and I've only tested with the "Ubuntu desktop" installation option.

## setup-remnux.sh

This script install [Remnux](https://remnux.org) and some other tools. Some of the added tools added are now up to date with the regular Remnux install script but is still installed.

The additions are:
* Ubuntu is updated
* Some general packages are installed. This includes bsdgames (some useful tools for CTFs), vim, tshark, exfat and more. Also a basic development environment is installed
* Installs open-vm-tools
* Create a basic directory structure
* Run the Remnux install script
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
* Install latest Radare2
* Install my resource repository
* Turn of sound

If you run *make dotfiles* my version of _.bashrc_, _.vimrc_ and _.bash_aliases_  are installed. There are a couple of aliases for docker images from Remnux. They use directories under _~/docker/<tool name>_.

## setup-sift.sh

This script installs [Sift](https://github.com/sans-dfir/sift-bootstrap)  and some additional tools listed below:

* Ubuntu is updated
* Some general packages are installed. This includes bsdgames (some useful tools for CTFs), vim, tshark, exfat and more. Also a basic development environment is installed
* Installs open-vm-tools
* Create a basic directory structure
* Run the Remnux install script
* Install Google Chrome
* Install Tekdefense Automater
* Install my resource repository
* Turn of sound

## Initial setup

First install git and clone the repository. Run all commands as a regular user and use *sudo* when needed.

    sudo apt-get install -y git
    git clone https://github.com/reuteras/remnux-tools.git
    cd remnux-tools

## Install

Choose if you would like to install Remnux or SIFT. Don't try to run both scripts in the same VM since it will not work. To install Remnux with my extra packages listed above:

    ./bin/setup-remux.sh      # or make install

Or to install SIFT with additions listed above:

    ./bin/setup-sift.sh

## Update

To update Remnux and tools run:

    ./bin/update-remnux.sh     # or make update

To update SIFT and tools run:

    ./bin/update-sift.sh

## Clean

This command will clean apt and write zeros to free space. Use this command if you like to shrink your VM size.

    ./bin/clean.sh      # or make clean

If you use VMware remember to run the following command to shrink the image:

    vmware-vdiskmanager -k Virtual\ Disk.vmdk
