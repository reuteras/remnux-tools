#!/bin/bash

function enable-new-didier() {
    if [[ -d ~/src/python/didierstevenssuite ]]; then
        chmod 755 ~/src/python/didierstevenssuite/cut-bytes.py
        chmod 755 ~/src/python/didierstevenssuite/decoder_*
        chmod 755 ~/src/python/didierstevenssuite/emldump.py
        chmod 755 ~/src/python/didierstevenssuite/hex-to-bin.py
        chmod 755 ~/src/python/didierstevenssuite/oledump.py
        chmod 755 ~/src/python/didierstevenssuite/pdf-parser.py
        chmod 755 ~/src/python/didierstevenssuite/pdfid.py
        chmod 755 ~/src/python/didierstevenssuite/plugin_*
        chmod 755 ~/src/python/didierstevenssuite/re-search.py
        chmod 755 ~/src/python/didierstevenssuite/translate.py
    fi
}

function info-message() {
    echo "**** INFO: $*"
}

# Turn off sound on start up
function turn-of-sound() {
    [ ! -e /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override ] && \
        echo -e '[com.canonical.unity-greeter]\nplay-ready-sound = false' | \
        sudo tee -a /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override > /dev/null && \
        sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
}

# General tools
function install-general-tools() {
    sudo apt-get -y -qq install \
        ascii \
        bsdgames \
        build-essential \
        ctags \
        curl \
        dos2unix \
        git \
        exfat-fuse \
        exfat-utils \
        libffi-dev \
        libimage-exiftool-perl \
        libncurses5-dev \
        libssl-dev \
        python-dev \
        python-virtualenv \
        sharutils \
        sqlite3 \
        tshark \
        vim \
        vim-doc \
        vim-scripts \
        virtualenvwrapper \
        whois \
        wswedish \
        zip
}

# Tools for Vmware
function install-vmware-tools() {
    sudo apt-get -y -qq install \
        fuse \
        open-vm-tools-desktop
}

# Install Google Chrome
function install-google-chrome() {
    if ! dpkg --status google-chrome-stable > /dev/null 2>&1 ; then
        cd /tmp || exit 0
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /dev/null
        sudo dpkg -i google-chrome-stable_current_amd64.deb || true
        sudo apt-get -qq -f -y install
        rm -f google-chrome-stable_current_amd64.deb
    fi
}

# Install Volatility
# First argument should be target path to check out volatility.
function install-volatility() {
    if [ $# -eq 0 ]; then
        echo "One argument expected for install-volatility()"
        exit 1
    fi
    if [ -d "$1" ]; then
        echo "$1 already exists!"
        exit 1
    fi
    git clone --quiet https://github.com/volatilityfoundation/volatility \
        "$1" && \
    cd "$1" && \
    pip install \
        Pillow \
        distorm3 \
        openpyxl \
        pycrypto \
        ujson \
        yara-python && \
    python setup.py install
}

function update-volatility(){
    [ -d "$1" ] && \
        cd "$1" && \
        git pull >> "$LOG" 2>&1 && \
        pip install --upgrade \
            Pillow \
            distorm3 \
            openpyxl \
            pycrypto \
            ujson \
            yara-python >> "$LOG" 2>&1 && \
        python setup.py install >> "$LOG" 2>&1
}

# This repo contians newer versions of Wireshark etc. Update again after adding
function install-pi-rho-security(){
    if [[ ! -e /etc/apt/sources.list.d/pi-rho-security-trusty.list ]]; then
        sudo add-apt-repository -y ppa:pi-rho/security
        sudo apt-get -qq update && sudo apt-get -qq -y dist-upgrade
        sudo apt-get -qq -y install html2text nasm && sudo apt-get autoremove -qq -y
    fi
}

# Cleanup functions
function cleanup-remnux(){
   if [[ -e ~/examples.desktop ]]; then
        rm -f ~/examples.desktop
    fi
    if [[ -e ~/Desktop/REMnux\ Cheat\ Sheet ]]; then
        echo "Clean Desktop."
        mkdir ~/Documents/Remnux
        mv ~/Desktop/REMnux* ~/Documents/Remnux/ || true
        mv ~/Desktop/*.pdf ~/Documents/Remnux/ || true
        ln -s /cases ~/Desktop/cases
        ln -s ~/Documents/Remnux ~/Desktop/Remnux || true
    fi
}

function cleanup-sift(){
    if [[ -e ~/examples.desktop ]]; then
        rm -f ~/examples.desktop
    fi
    if [[ -e ~/Desktop/SANS-DFIR.pdf ]]; then
        echo "Clean Desktop."
        mkdir ~/Documents/SIFT || true
        mv ~/Desktop/*.pdf ~/Documents/SIFT/ || true
        ln -s ~/Documents/SIFT ~/Desktop/SIFT || true
    fi
}

# Install single file scripts

# http://phishme.com/powerpoint-and-custom-actions/
function install-psparser(){
    [ ! -e ~/src/bin/psparser.py ] && wget -q -O ~/src/bin/psparser.py \
        https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py >> "$LOG" 2>&1 && \
        chmod +x ~/src/bin/psparser.py && \
        info-message "Installed psparser.py"
}

function update-psparser(){
    rm -f ~/src/bin/psparser.py
    install-psparser
}

# https://www.virustotal.com/en/documentation/public-api/#getting-file-scans
function install-vt-py(){
    [ ! -e ~/src/bin/vt.py ] && wget -q -O ~/src/bin/vt.py \
        https://raw.githubusercontent.com/Xen0ph0n/VirusTotal_API_Tool/master/vt.py >> "$LOG" 2>&1 && \
        chmod +x ~/src/bin/vt.py && \
        info-message "Installed vt.py."
}

function install-vt-py(){
    rm -f ~/src/bin/vt.py
    install-vt-py
}

# https://testssl.sh/
function install-testssl(){
    [ ! -e ~/src/bin/testssl.sh ] && wget -q -O ~/src/bin/testssl.sh \
        https://testssl.sh/testssl.sh >> "$LOG" 2>&1 && \
        chmod +x ~/src/bin/testssl.sh && \
        info-message "Installed testssl.sh."
}

function install-testssl(){
    rm -f ~/src/bin/testssl.sh
    install-testssl
}

# Fireeye floss
function install-floss(){
    [ ! -e ~/src/bin/floss ] && wget -q -O ~/src/bin/floss \
        https://s3.amazonaws.com/build-artifacts.floss.flare.fireeye.com/travis/linux/dist/floss >> "$LOG" 2>&1 && \
        chmod +x ~/src/bin/floss && \
        info-message "Installed floss."
}

function install-floss(){
    rm -f ~/src/bin/floss
    install-floss
}

# Install automater
# http://www.tekdefense.com/automater/
function install-automater(){
    [ ! -d ~/src/python/automater ] && \
        git clone --quiet https://github.com/1aN0rmus/TekDefense-Automater.git \
            ~/src/python/automater >> "$LOG" 2>&1 && \
        cd ~/src/python/automater && \
        mkvirtualenv automater >> "$LOG" 2>&1 && \
        setvirtualenvproject >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Checked out Automater."
}

function update-automater(){
    [ -d ~/src/python/automater ] && \
        workon automater && \
        git pull >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Updated Automater."
}

# https://n0where.net/malware-analysis-damm/
# Also install a seperate version of the latest volatility in this env.
function install-damm(){
# shellcheck disable=SC2102
    [ ! -d ~/src/python/damm ] && \
        mkdir -p ~/src/python/damm && \
        git clone --quiet https://github.com/504ensicsLabs/DAMM \
            ~/src/python/damm/damm >> "$LOG" 2>&1 && \
        cd ~/src/python/damm/damm && \
        mkvirtualenv damm >> "$LOG" 2>&1 && \
        setvirtualenvproject >> "$LOG" 2>&1 && \
        pip install --upgrade pip >> "$LOG" 2>&1 && \
        pip install --upgrade urllib3[secure] >> "$LOG" 2>&1 && \
        install-volatility ~/src/python/damm/volatility >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Checked out DAMM."
}

function update-damm(){
    [ -d ~/src/python/damm ] && \
        workon damm && \
        git pull >> "$LOG" 2>&1 && \
        pip install --upgrade pip >> "$LOG" 2>&1 && \
        update-volatility ~/src/python/damm/volatility && \
        deactivate && \
        info-message "Updated DAMM."
}

# Install Volutility
function install-volutility(){
    # shellcheck disable=SC2102
    [ ! -d ~/src/python/volatility ] && \
        mkdir -p ~/src/python/volutility && \
        mkvirtualenv volutility >> "$LOG" 2>&1 && \
        echo "Start MongoDB with docker-mongodb" > ~/src/python/volutility/README && \
        pip install --upgrade pip >> "$LOG" 2>&1 && \
        pip install --upgrade urllib3[secure] >> "$LOG" 2>&1 && \
        install-volatility ~/src/python/volutility/volatility >> "$LOG" 2>&1 && \
        git clone https://github.com/kevthehermit/VolUtility \
            ~/src/python/volutility/volutility >> "$LOG" 2>&1 && \
        cd ~/src/python/volutility/volutility && \
        pip install -r requirements.txt >> "$LOG" 2>&1 && \
        pip install virustotal-api yara-python >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Installed Volutility."
}

function update-volutility(){
    [ -d ~/src/python/volatility ] && \
        workon volutility && \
        pip install --upgrade pip >> "$LOG" 2>&1 && \
        update-volatility ~/src/python/volutility/volatility >> "$LOG" 2>&1 && \
        cd ~/src/python/volutility/volutility && \
        git pull >> "$LOG" 2>&1 && \
        pip install --upgrade -r requirements.txt >> "$LOG" 2>&1 && \
        pip install --upgrade virustotal-api yara-python >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Updated Volutility."
}

# Keep a seperate environment for volatility (to be able to upgrade separatly)
function install-volatility-env(){
    # shellcheck disable=SC2102
    [ ! -d ~/src/python/volatility ] && \
        mkdir -p ~/src/python/volatility && \
        mkvirtualenv volatility >> "$LOG" 2>&1 && \
        pip install --upgrade pip >> "$LOG" 2>&1 && \
        pip install --upgrade urllib3[secure] >> "$LOG" 2>&1 && \
        install-volatility ~/src/python/volatility/volatility >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Checked out Volatility."
}

function update-volatility-env(){
    [ -d ~/src/python/volatility ] && \
        workon volatility && \
        cd ~/src/python/volatility && \
        update-volatility ~/src/python/volatility/volatility && \
        deactivate && \
        info-message "Updated Volatility."
}

# https://github.com/DidierStevens/DidierStevensSuite
function install-didierstevenssuite(){
    [ ! -d ~/src/python/didierstevenssuite ] && \
        git clone --quiet https://github.com/DidierStevens/DidierStevensSuite.git \
            ~/src/python/didierstevenssuite >> "$LOG" 2>&1 && \
        mkvirtualenv didierstevenssuite >> "$LOG" 2>&1 && \
        setvirtualenvproject >> "$LOG" 2>&1 && \
        enable-new-didier && \
        deactivate && \
        info-message "Checked out DidierStevensSuite."
}

function update-didierstevenssuite(){
    [ -d ~/src/python/didierstevenssuite ] && \
        workon didierstevenssuite && \
        cd ~/src/python/didierstevenssuite && \
        git fetch --all >> "$LOG" 2>&1 && \
        git reset --hard origin/master >> "$LOG" 2>&1 && \
        enable-new-didier && \
        deactivate && \
        info-message "Updated DidierStevensSuite."
}

# https://github.com/decalage2/oletools.git
function install-oletools(){
    # shellcheck disable=SC2102
    [ ! -d ~/.virtualenvs/oletools ] && \
        mkvirtualenv oletools >> "$LOG" 2>&1 && \
        pip install --upgrade pip >> "$LOG" 2>&1 && \
        pip install --upgrade urllib3[secure] >> "$LOG" 2>&1 && \
        pip install oletools >> "$LOG" 2>&1 && \
        info-message "Installed oletools."
}

function update-oletools(){
    [ -d ~/.virtualenvs/oletools ] && \
        workon oletools && \
        pip install --upgrade pip >> "$LOG" 2>&1 && \
        pip install --upgrade oletools >> "$LOG" 2>&1 && \
        info-message "Updated oletools."
}

# Rekall
function install-rekall(){
    [ ! -d ~/.virtualenvs/rekall ] && \
        mkvirtualenv rekall >> "$LOG" 2>&1 && \
        pip install --upgrade pip setuptools >> "$LOG" 2>&1 && \
        pip install rekall rekall-gui >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Installed rekall."
}

function update-rekall(){
    [ -d ~/.virtualenvs/rekall ] && \
        workon rekall && \
        pip install --upgrade pip setuptools >> "$LOG" 2>&1 && \
        pip install --upgrade rekall rekall-gui >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Updated rekall."
}

# pcodedmp
function install-pcodedmp(){
    [ ! -d ~/src/python/pcodedmp ] && \
        git clone --quiet https://github.com/bontchev/pcodedmp.git
            ~/src/python/pcodedmp >> "$LOG" 2>&1 && \
        mkvirtualenv pcodedmp >> "$LOG" 2>&1 && \
        pip install --upgrade pip setuptools >> "$LOG" 2>&1 && \
        pip install oletools >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Installed pcodedmp."
}

function update-pcodedmp(){
    [ -d ~/src/python/pcodedmp ] && \
        workon pcodedmp && \
        cd ~/src/python/pcodedmp && \
        git fetch --all >> "$LOG" 2>&1 && \
        git reset --hard origin/master >> "$LOG" 2>&1 && \
        deactivate && \
        info-message "Updated pcodedmp."
}

# https://github.com/keydet89/RegRipper2.8
function install-regripper(){
    [ ! -d ~/src/git/RegRipper2.8 ] && \
        git clone --quiet https://github.com/keydet89/RegRipper2.8.git \
            ~/src/git/RegRipper2.8 >> "$LOG" 2>&1 && \
        info-message "Checked out RegRipper2.8." && \
        ln -s ~/remnux-tools/files/regripper2.8 ~/src/bin/regripper2.8 && \
        chmod 755 ~/remnux-tools/files/regripper2.8
}

# Checkout git repo to directory
function checkout-git-repo(){
    [ ! -d ~/src/git/"$2" ] && \
        git clone --quiet "$1" ~/src/git/"$2" >> "$LOG" 2>&1 && \
        info-message "Checkout git repo $1"
}

# https://github.com/radare/radare2
function install-radare2(){
    # shellcheck disable=SC2024
    [ ! -d ~/src/git/radare2 ] && \
        info-message "Starting installation of radare2." && \
        sudo apt-get remove -y radare2 >> "$LOG" 2>&1 && \
        sudo apt-get autoremove -y >> "$LOG" 2>&1 && \
        checkout-git-repo https://github.com/radare/radare2.git radare2 && \
        cd ~/src/git/radare2 && \
        ./sys/install.sh >> "$LOG" 2>&1 && \
        info-message "Installated radare2."
}

function update-radare2(){
    # shellcheck disable=SC2024
    [ -d ~/src/git/radare2 ] && \
        sudo apt-get remove -y radare2 >> "$LOG" 2>&1 && \
        sudo apt-get autoremove -y >> "$LOG" 2>&1 && \
        cd ~/src/git/radare2 && \
        git pull >> "$LOG" 2>&1 && \
        ./sys/install.sh >> "$LOG" 2>&1 && \
        info-message "Updated radare2."
}
