# remnux-tools

The setup has changed a lot lately and it is recommended to install from scratch.

There are two major scripts for installs:

* setup-remnux.sh - install [Remnux](https://remnux.org)
* setup-sift.sh - install [Sift](https://github.com/sans-dfir/sift-bootstrap)

Earlier the Remnux and Sift where installed together in one VM. Most of the addons have been moved to the Remnux script. Both scripts starts from a vanilla Ubuntu 14.04 LTS. Personally I start the installation from the [mini.iso](http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/netboot/mini.iso). I've only tested the script with the "Ubuntu desktop" as the only thing to install.

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
* Turn of sound

If you run *make dotfiles* my version of _.bashrc_, _.vimrc_ and _.bash_aliases_  are installed. There are a couple of aliases for docker images from Remnux. They use directories under _~/docker/<tool name>_.

## Common setup

First install git and clone the repository. Run all commands as a regular user and use *sudo* when needed.

    sudo apt-get install -y git
    git clone https://github.com/reuteras/remnux-tools.git
    cd remnux-tools

## Install

Choose to install Remnux or SIFT. Don't try to install both in the same VM since it will not work. To install Remnux:

    ./bin/setup-remux.sh      # or make install

Or to install SIFT:

    ./bin/setup-sift.sh

## Update

To update Remnux and other tools installed do:

    ./bin/update-remnux.sh     # or make update

To update SIFT run:

    ./bin/update-sift.sh

## Clean

This command will clean apt and write zeros to free space. Use this command if you like to shrink your VM size.

    ./bin/clean.sh      # or make clean

