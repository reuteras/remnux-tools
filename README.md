# remnux-tools

This script assumes that you have installed a vanilla Ubuntu 14.04 LTS. It then installs the tools from

* [Remnux](https://remnux.org)
* [Sift](https://github.com/sans-dfir/sift-bootstrap)

Also some single packages are installed such as vim, open-vm-tools-desktop. Google Chrome is also installed.

If you run *make* my version of _.bashrc_, _.vimrc_ and _.bash_aliases_  are installed. There are a couple of aliases for docker images from Remnux. They use directories under _~/cases/docker/<tool name>_.

Some scripts from other repositories are installed:
* [psparser.py](https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py) - [example use](http://phishme.com/powerpoint-and-custom-actions/)
* [https://zeltser.com/convert-shellcode-to-assembly/](https://github.com/MarioVilas/shellcode_tools/blob/master/shellcode2exe.py) - [introduction](https://zeltser.com/convert-shellcode-to-assembly/)

## Install

    sudo apt-get install -y git
    git clone https://github.com/reuteras/remnux-tools.git
    cd remnux-tools
    ./bin/setup.sh

## Update

    ./bin/update.sh

