# remnux-tools

This script installs Remnux on a vanilla Ubuntu 14.04 LTS. I start the installation from the [mini.iso](http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/netboot/mini.iso). Currently I select "Ubuntu desktop" as the only thing to install. The script then installs the [Remnux](https://remnux.org) tools and some other scripts and tools.

Previously this script also installed the [Sift](https://github.com/sans-dfir/sift-bootstrap) tools. Due to problems lately I've stopped doing that. I might create a separate script for SIFT in the future.

The repository _ppa:pi-rho/security_ is activated and newer versions of many tools are updated from there. Google Chrome is installed.

Standard tools from Ubuntu and in some cases the ppa listed above installed are:

* ctags
* curl
* fuse, exfat-fuse and exfat-utils
* git
* html2text
* nasm 
* open-vm-tools-desktop
* python-virtualenv
* tshark
* vim, vim-doc  and vim-scripts
* zip

If you run *make dotfiles* my version of _.bashrc_, _.vimrc_ and _.bash_aliases_  are installed. There are a couple of aliases for docker images from Remnux. They use directories under _~/cases/docker/<tool name>_.

Some scripts from other repositories are installed:
* [psparser.py](https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py) - [example use](http://phishme.com/powerpoint-and-custom-actions/)
* [https://zeltser.com/convert-shellcode-to-assembly/](https://github.com/MarioVilas/shellcode_tools/blob/master/shellcode2exe.py) - [introduction](https://zeltser.com/convert-shellcode-to-assembly/)
* [RegRipper2.8](https://github.com/keydet89/RegRipper2.8)
* [DAMM](https://n0where.net/malware-analysis-damm/)

## Install

    sudo apt-get install -y git
    git clone https://github.com/reuteras/remnux-tools.git
    cd remnux-tools
    ./bin/setup.sh      # or make install

## Update

    ./bin/update.sh     # or make update

## Clean

    ./bin/clean.sh      # or make clean

