#!/bin/bash

set -e
LOG=/tmp/remnux-tools.log

info-message "Starting installation of remnux-tools."

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."

info-message "Updating Ubuntu."
sudo apt-get -qq update && sudo apt-get -qq -y dist-upgrade

info-message "Installing general tools."
install-general-tools > $LOG
info-message "Installing tools for VMware."
install-vmware-tools >> $LOG

if [ ! -d ~/src ]; then
    mkdir -p ~/src/bin
fi

if [ ! -d ~/src/git ]; then
    mkdir -p ~/src/git
fi

if [ ! -d ~/src/python ]; then
    mkdir -p ~/src/python
fi

if [ ! -d ~/docker ]; then
    mkdir -p ~/docker
fi

for dir in pescanner radare2 mastiff thug v8 viper; do
    if [ ! -d ~/docker/$dir ]; then
        mkdir ~/docker/$dir
        chmod 777 ~/docker/$dir
    fi
done

# Install Remnux
if [[ ! -e ~/.config/.remnux ]]; then
    wget --quiet -O - https://remnux.org/get-remnux.sh | sudo bash
    touch ~/.config/.remnux
fi

install-google-chrome

# This repo contians newer versions of Wireshark etc. Update again after adding
if [[ ! -e /etc/apt/sources.list.d/pi-rho-security-trusty.list ]]; then
    sudo add-apt-repository -y ppa:pi-rho/security
    sudo apt-get -qq update && sudo apt-get -qq -y dist-upgrade
    sudo apt-get -qq -y install html2text nasm && sudo apt-get autoremove -qq -y
fi

# Clean up
if [[ -e ~/examples.desktop ]]; then
    rm -f ~/examples.desktop
fi
if [[ -e ~/Desktop/SANS-DFIR.pdf ]]; then
    echo "Clean Desktop."
    mkdir ~/Documents/Remnux_SIFT
    mv ~/Desktop/REMnux* ~/Documents/Remnux_SIFT/
    mv ~/Desktop/*.pdf ~/Documents/Remnux_SIFT/
    rm -f ~/Desktop/cases
fi

# Add single file scripts from different sources
# http://phishme.com/powerpoint-and-custom-actions/
[ ! -e ~/src/bin/psparser.py ] && wget -q -O ~/src/bin/psparser.py \
    https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py && \
    chmod +x ~/src/bin/psparser.py && \
    info-message "Installed psparser.py"
# https://www.virustotal.com/en/documentation/public-api/#getting-file-scans
[ ! -e ~/src/bin/vt.py ] && wget -q -O ~/src/bin/vt.py \
    https://raw.githubusercontent.com/Xen0ph0n/VirusTotal_API_Tool/master/vt.py && \
    chmod +x ~/src/bin/vt.py && \
    info-message "Installed vt.py."
# https://testssl.sh/
[ ! -e ~/src/bin/testssl.sh ] && wget -q -O ~/src/bin/testssl.sh \
    https://testssl.sh/testssl.sh && \
    chmod +x ~/src/bin/testssl.sh && \
    info-message "Installed testssl.sh."
# Fireeye floss
[ ! -e ~/src/bin/floss ] && wget -q -O ~/src/bin/floss \
    https://s3.amazonaws.com/build-artifacts.floss.flare.fireeye.com/travis/linux/dist/floss && \
    chmod +x ~/src/bin/floss && \
    info-message "Installed floss."

# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Make sure pip is up to date
sudo -H pip install --upgrade pip

# Install pip lib globally
sudo -H pip install colorclass

# Add git repos
# http://www.tekdefense.com/automater/
[ ! -d ~/src/python/automater ] && \
    git clone --quiet https://github.com/1aN0rmus/TekDefense-Automater.git \
        ~/src/python/automater && \
    cd ~/src/python/automater && \
    mkvirtualenv automater && \
    setvirtualenvproject && \
    deactivate && \
    info-message "Checked out Automater."

# https://n0where.net/malware-analysis-damm/
# Also install a seperate version of the latest volatility in this env.
# shellcheck disable=SC2102
[ ! -d ~/src/python/damm ] && \
    mkdir -p ~/src/python/damm && \
    git clone --quiet https://github.com/504ensicsLabs/DAMM \
        ~/src/python/damm/damm && \
    cd ~/src/python/damm/damm && \
    mkvirtualenv damm && \
    setvirtualenvproject && \
    pip install --upgrade pip && \
    pip install --upgrade urllib3[secure] && \
    install-volatility ~/src/python/damm/volatility && \
    deactivate && \
    info-message "Checked out DAMM."

# Install Volutility
# shellcheck disable=SC2102
[ ! -d ~/src/python/volatility ] && \
    mkdir -p ~/src/python/volutility && \
    mkvirtualenv volutility && \
    echo "Start MongoDB with docker-mongodb" > ~/src/python/volutility/README && \
    pip install --upgrade pip && \
    pip install --upgrade urllib3[secure] && \
    install-volatility ~/src/python/volutility/volatility && \
    git clone https://github.com/kevthehermit/VolUtility \
        ~/src/python/volutility/volutility && \
    cd ~/src/python/volutility/volutility && \
    pip install -r requirements.txt && \
    pip install virustotal-api yara-python && \
    deactivate && \
    info-message "Installed Volutility."

# Keep a seperate environment for volatility (to be able to upgrade separatly)
# shellcheck disable=SC2102
[ ! -d ~/src/python/volatility ] && \
    mkdir -p ~/src/python/volatility && \
    mkvirtualenv volatility && \
    pip install --upgrade pip && \
    pip install --upgrade urllib3[secure] && \
    install-volatility ~/src/python/volatility/volatility && \
    deactivate && \
    info-message "Checked out Volatility."

# https://github.com/DidierStevens/DidierStevensSuite
[ ! -d ~/src/python/didierstevenssuite ] && \
    git clone --quiet https://github.com/DidierStevens/DidierStevensSuite.git \
    ~/src/python/didierstevenssuite && \
    mkvirtualenv didierstevenssuite && \
    setvirtualenvproject && \
    deactivate && \
    enable-new-didier && \
    info-message "Checked out DidierStevensSuite."

# https://github.com/decalage2/oletools.git
# shellcheck disable=SC2102
[ ! -d ~/.virtualenvs/oletools ] && \
    mkvirtualenv oletools && \
    pip install --upgrade pip && \
    pip install --upgrade urllib3[secure] && \
    pip install oletools && \
    info-message "Installed oletools."

# Fix problem with pip - https://github.com/pypa/pip/issues/1093
#[ ! -e /usr/local/bin/pip ] && \
#    sudo apt-get remove -yqq --auto-remove python-pip && \
#    wget --quiet -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
#    sudo -H python /tmp/get-pip.py && \
#    sudo ln -s /usr/local/bin/pip /usr/bin/pip && \
#    sudo rm /tmp/get-pip.py && \
#    sudo -H pip install pyopenssl ndg-httpsclient pyasn1 && \
#    info-message "Install pip from pypa.io."

# Python virtualenv
# Checkout Rekall to fix problem with python-dateutil being newer.
[ ! -d ~/.virtualenvs/rekall ] && \
    mkvirtualenv rekall && \
    echo -n "Update pip and setuptools for rekall." && \
    pip install -U pip setuptools && \
    echo -n "Start installation of rekall." && \
    pip install rekall rekall-gui > /dev/null && \
    deactivate && \
    echo " Done."

# Other tools
# https://github.com/keydet89/RegRipper2.8
[ ! -d ~/src/git/RegRipper2.8 ] && \
    git clone --quiet https://github.com/keydet89/RegRipper2.8.git \
        ~/src/git/RegRipper2.8 && \
    info-message "Checked out RegRipper2.8." && \
    cp ~/remnux-tools/files/regripper2.8 ~/src/bin/regripper2.8 && \
    chmod 755 ~/src/bin/regripper2.8

# https://github.com/Yara-Rules/rules.git
[ ! -d ~/src/git/rules ] && \
    git clone --quiet https://github.com/Yara-Rules/rules.git ~/src/git/rules && \
    info-message "Checked out Yara-Rules."

# Turn off sound on start up
turn-of-sound

# Info manual config
if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "##################################################################"
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "4. Change Desktop Background :)"
    echo "5. Run make dotfiles in ~/remnux-tools for .bashrc etc."
    echo "##################################################################"
    touch ~/.config/.manual_conf
fi
