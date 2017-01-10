#!/bin/bash

set -e
LOG=/tmp/remnux-tools.log
touch $LOG

# Make a fake sudo to get password before output
sudo touch $LOG

# shellcheck source=/dev/null
[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."
info-message "Starting installation of remnux-tools."
info-message "Details logged to $LOG."
info-message "Updating Ubuntu."
info-message "Running apt-get update."
# shellcheck disable=SC2024
sudo apt-get -qq update >> $LOG 2>&1
info-message "Running apt-get dist-upgrade."
# shellcheck disable=SC2024
sudo apt-get -qq -y dist-upgrade >> $LOG 2>&1

info-message "Installing general tools."
install-general-tools >> $LOG 2>&1
info-message "Installing tools for VMware."
install-vmware-tools >> $LOG 2>&1

info-message "Create directory structure."
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
    info-message "Start installation of Remnux."
    wget --quiet -O - https://remnux.org/get-remnux.sh | sudo bash
    touch ~/.config/.remnux
    info-message "Remnux installation finished."
fi

info-message "Install Google Chrome."
install-google-chrome >> $LOG 2>&1

info-message "Enable ppa:pi-rho/security and install updated packages."
install-pi-rho-security >> $LOG 2>&1

info-message "Clean up folders and files."
cleanup >> $LOG 2>&1

# Add single file scripts from different sources
# http://phishme.com/powerpoint-and-custom-actions/
[ ! -e ~/src/bin/psparser.py ] && wget -q -O ~/src/bin/psparser.py \
    https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py >> $LOG 2>&1 && \
    chmod +x ~/src/bin/psparser.py && \
    info-message "Installed psparser.py"
# https://www.virustotal.com/en/documentation/public-api/#getting-file-scans
[ ! -e ~/src/bin/vt.py ] && wget -q -O ~/src/bin/vt.py \
    https://raw.githubusercontent.com/Xen0ph0n/VirusTotal_API_Tool/master/vt.py >> $LOG 2>&1 && \
    chmod +x ~/src/bin/vt.py && \
    info-message "Installed vt.py."
# https://testssl.sh/
[ ! -e ~/src/bin/testssl.sh ] && wget -q -O ~/src/bin/testssl.sh \
    https://testssl.sh/testssl.sh >> $LOG 2>&1 && \
    chmod +x ~/src/bin/testssl.sh && \
    info-message "Installed testssl.sh."
# Fireeye floss
[ ! -e ~/src/bin/floss ] && wget -q -O ~/src/bin/floss \
    https://s3.amazonaws.com/build-artifacts.floss.flare.fireeye.com/travis/linux/dist/floss >> $LOG 2>&1 && \
    chmod +x ~/src/bin/floss && \
    info-message "Installed floss."

# Install pip lib globally
# shellcheck disable=SC2024
sudo -H pip install colorclass >> $LOG 2>&1
info-message "Installed python colorclass."

info-message "Setup virtualenvwrapper."
# Use virtualenvwrapper for python tools
export PROJECT_HOME="$HOME"/src/python
# shellcheck source=/dev/null
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Add git repos
# http://www.tekdefense.com/automater/
[ ! -d ~/src/python/automater ] && \
    git clone --quiet https://github.com/1aN0rmus/TekDefense-Automater.git \
        ~/src/python/automater >> $LOG 2>&1 && \
    cd ~/src/python/automater && \
    mkvirtualenv automater >> $LOG 2>&1 && \
    setvirtualenvproject >> $LOG 2>&1 && \
    deactivate && \
    info-message "Checked out Automater."

# https://n0where.net/malware-analysis-damm/
# Also install a seperate version of the latest volatility in this env.
# shellcheck disable=SC2102
[ ! -d ~/src/python/damm ] && \
    mkdir -p ~/src/python/damm && \
    git clone --quiet https://github.com/504ensicsLabs/DAMM \
        ~/src/python/damm/damm >> $LOG 2>&1 && \
    cd ~/src/python/damm/damm && \
    mkvirtualenv damm >> $LOG 2>&1 && \
    setvirtualenvproject >> $LOG 2>&1 && \
    pip install --upgrade pip >> $LOG 2>&1 && \
    pip install --upgrade urllib3[secure] >> $LOG 2>&1 && \
    install-volatility ~/src/python/damm/volatility >> $LOG 2>&1 && \
    deactivate && \
    info-message "Checked out DAMM."

# Install Volutility
# shellcheck disable=SC2102
[ ! -d ~/src/python/volatility ] && \
    mkdir -p ~/src/python/volutility && \
    mkvirtualenv volutility >> $LOG 2>&1 && \
    echo "Start MongoDB with docker-mongodb" > ~/src/python/volutility/README && \
    pip install --upgrade pip >> $LOG 2>&1 && \
    pip install --upgrade urllib3[secure] >> $LOG 2>&1 && \
    install-volatility ~/src/python/volutility/volatility >> $LOG 2>&1 && \
    git clone https://github.com/kevthehermit/VolUtility \
        ~/src/python/volutility/volutility >> $LOG 2>&1 && \
    cd ~/src/python/volutility/volutility && \
    pip install -r requirements.txt >> $LOG 2>&1 && \
    pip install virustotal-api yara-python >> $LOG 2>&1 && \
    deactivate && \
    info-message "Installed Volutility."

# Keep a seperate environment for volatility (to be able to upgrade separatly)
# shellcheck disable=SC2102
[ ! -d ~/src/python/volatility ] && \
    mkdir -p ~/src/python/volatility && \
    mkvirtualenv volatility >> $LOG 2>&1 && \
    pip install --upgrade pip >> $LOG 2>&1 && \
    pip install --upgrade urllib3[secure] >> $LOG 2>&1 && \
    install-volatility ~/src/python/volatility/volatility >> $LOG 2>&1 && \
    deactivate && \
    info-message "Checked out Volatility."

# https://github.com/DidierStevens/DidierStevensSuite
[ ! -d ~/src/python/didierstevenssuite ] && \
    git clone --quiet https://github.com/DidierStevens/DidierStevensSuite.git \
        ~/src/python/didierstevenssuite >> $LOG 2>&1 && \
    mkvirtualenv didierstevenssuite >> $LOG 2>&1 && \
    setvirtualenvproject >> $LOG 2>&1 && \
    deactivate && \
    enable-new-didier && \
    info-message "Checked out DidierStevensSuite."

# https://github.com/decalage2/oletools.git
# shellcheck disable=SC2102
[ ! -d ~/.virtualenvs/oletools ] && \
    mkvirtualenv oletools >> $LOG 2>&1 && \
    pip install --upgrade pip >> $LOG 2>&1 && \
    pip install --upgrade urllib3[secure] >> $LOG 2>&1 && \
    pip install oletools >> $LOG 2>&1 && \
    info-message "Installed oletools."

# Python virtualenv
# Checkout Rekall to fix problem with python-dateutil being newer.
[ ! -d ~/.virtualenvs/rekall ] && \
    mkvirtualenv rekall >> $LOG 2>&1 && \
    pip install -U pip setuptools >> $LOG 2>&1 && \
    pip install rekall rekall-gui >> $LOG 2>&1 && \
    deactivate && \
    info-message "Installed rekall."

# Other tools
# https://github.com/keydet89/RegRipper2.8
[ ! -d ~/src/git/RegRipper2.8 ] && \
    git clone --quiet https://github.com/keydet89/RegRipper2.8.git \
        ~/src/git/RegRipper2.8 >> $LOG 2>&1 && \
    info-message "Checked out RegRipper2.8." && \
    cp ~/remnux-tools/files/regripper2.8 ~/src/bin/regripper2.8 && \
    chmod 755 ~/src/bin/regripper2.8

# https://github.com/Yara-Rules/rules
[ ! -d ~/src/git/rules ] && \
    git clone --quiet https://github.com/Yara-Rules/rules.git \
        ~/src/git/rules >> $LOG 2>&1 && \
    info-message "Checked out Yara-Rules."

# https://github.com/reuteras/resources
[ ! -d ~/src/git/resources ] && \
    git clone --quiet https://github.com/reuteras/resources.git \
        ~/src/git/resources >> $LOG 2>&1 && \
    info-message "Checked out resources."

# https://github.com/radare/radare2
# shellcheck disable=SC2024
[ ! -d ~/src/git/radare2 ] && \
    info-message "Starting installation of radare2." && \
    sudo apt-get remove -y radare2 >> $LOG 2>&1 && \
    sudo apt-get autoremove -y >> $LOG 2>&1 && \
    git clone --quiet https://github.com/radare/radare2.git \
        ~/src/git/radare2 >> $LOG 2>&1 && \
    cd ~/src/git/radare2 && \
    ./sys/install.sh >> $LOG 2>&1 && \
    info-message "Installation of radare2 done."

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
