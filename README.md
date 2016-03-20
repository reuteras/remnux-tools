# remnux-tools

This script assumes that you have installed a vanilla Ubuntu 14.04 LTS. It then installs the tools from

* [Remnux](https://remnux.org)
* [Sift](https://github.com/sans-dfir/sift-bootstrap)

Also some single packages are installed such as vim, open-vm-tools-desktop. Google Chrome is also installed.

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

## TODO

Thinking about adding the following:

* https://github.com/sysforensics/VirusTotal
* https://github.com/Dutchy-/volatility-plugins
* https://github.com/fireeye/flare-floss
* https://github.com/tribalchicken/volatility-bitlocker (https://tribalchicken.com.au/technical/recovering-bitlocker-keys-on-windows-8-1-and-10/)
