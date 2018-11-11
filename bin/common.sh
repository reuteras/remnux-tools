#!/bin/bash

function enable-new-didier() {
    echo "enable-new-didier" >> "$LOG" 2>&1
    if [[ -d ~/src/python/didierstevenssuite ]]; then
        chmod 755 ~/src/python/didierstevenssuite/
        chmod 755 ~/src/python/didierstevenssuite/base64dump.py
        chmod 755 ~/src/python/didierstevenssuite/byte-stats.py
        chmod 755 ~/src/python/didierstevenssuite/cipher-tool.py
        chmod 755 ~/src/python/didierstevenssuite/count.py
        chmod 755 ~/src/python/didierstevenssuite/cut-bytes.py
        chmod 755 ~/src/python/didierstevenssuite/decode*
        chmod 755 ~/src/python/didierstevenssuite/defuzzer.py
        chmod 755 ~/src/python/didierstevenssuite/emldump.py
        chmod 755 ~/src/python/didierstevenssuite/extractscripts.py
        chmod 755 ~/src/python/didierstevenssuite/file2vbscript.py
        chmod 755 ~/src/python/didierstevenssuite/find-file-in-file.py
        chmod 755 ~/src/python/didierstevenssuite/hex-to-bin.py
        chmod 755 ~/src/python/didierstevenssuite/numbers*
        chmod 755 ~/src/python/didierstevenssuite/oledump.py
        chmod 755 ~/src/python/didierstevenssuite/pdf-parser.py
        chmod 755 ~/src/python/didierstevenssuite/pdfid.py
        chmod 755 ~/src/python/didierstevenssuite/pecheck.py
        chmod 755 ~/src/python/didierstevenssuite/plugin_*
        chmod 755 ~/src/python/didierstevenssuite/python-per-line.py
        chmod 755 ~/src/python/didierstevenssuite/reextra.py
        chmod 755 ~/src/python/didierstevenssuite/re-search.py
        chmod 755 ~/src/python/didierstevenssuite/rtfdump.py
        chmod 755 ~/src/python/didierstevenssuite/sets.py
        chmod 755 ~/src/python/didierstevenssuite/shellcode*
        chmod 755 ~/src/python/didierstevenssuite/split.py
        chmod 755 ~/src/python/didierstevenssuite/translate.py
        chmod 755 ~/src/python/didierstevenssuite/zipdump.py
    fi
}

function info-message() {
    echo "**** INFO: $*"
}

function error-message() {
    (>&2 echo "**** ERROR: $*")
}

# Turn off sound on start up
function turn-of-sound() {
    if [[ ! -e /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override ]]; then
        echo "turn-of-sound" >> "$LOG" 2>&1
        echo -e '[com.canonical.unity-greeter]\nplay-ready-sound = false' | \
        sudo tee -a /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override > /dev/null
        sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
    fi
}

function update-ubuntu(){
    info-message "Updating Ubuntu."
    info-message "Running apt update."
    # shellcheck disable=SC2024
    sudo apt -qq update >> "$LOG" 2>&1
    info-message "Running apt dist-upgrade."
    # shellcheck disable=SC2024
    while ! sudo apt -y dist-upgrade --force-yes >> "$LOG" 2>&1 ; do
        echo "APT busy. Will retry in 10 seconds."
        sleep 10
    done
}

# General tools
function install-general-tools(){
    info-message "Installing general tools."
    # shellcheck disable=SC2024
    sudo DEBIAN_FRONTEND=noninteractive apt -y -qq install \
        ascii \
        bless \
        bsdgames \
        build-essential \
        ctags \
        curl \
        dos2unix \
        exfat-fuse \
        exfat-utils \
        git \
        htop \
        libffi-dev \
        libimage-exiftool-perl \
        libncurses5-dev \
        libssl-dev \
        p7zip \
        python-dev \
        python3-dev \
        python-virtualenv \
        screen \
        sharutils \
        sqlite3 \
        sqlitebrowser \
        strace \
        tmux \
        tshark \
        unrar \
        vim \
        vim-doc \
        vim-scripts \
        virtualenvwrapper \
        wget \
        whois \
        wswedish \
        zip >> "$LOG" 2>&1
}

# Tools for Vmware
function install-vmware-tools(){
    info-message "Installing tools for VMware."
    # shellcheck disable=SC2024
    sudo apt -y -qq install \
        fuse \
        open-vm-tools-desktop >> "$LOG" 2>&1
}

function install-apt-remnux(){
    info-message "Installing apt-packages for REMnux."
    # sleuthkit provides hfind(1)
    # shellcheck disable=SC2024
    sudo apt -y -qq install \
        mpack \
        python3-pip \
        sleuthkit \
        testdisk >> "$LOG" 2>&1
}

function install-apt-moloch(){
    info-message "Installing apt-packages for Moloch."
    # shellcheck disable=SC2024
    sudo apt -y -qq install \
        bash-completion \
        cifs-utils \
        nfs-common \
        ngrep \
        python3-yara \
        samba-common \
        samba-common-bin \
        tcpslice \
        tshark \
        yara \
        yara-doc \
        wireshark >> "$LOG" 2>&1
}

# Install Google Chrome
function install-google-chrome() {
    if ! dpkg --status google-chrome-stable > /dev/null 2>&1 ; then
        info-message "Installing Google Chrome."
        cd /tmp || exit "Couldn't cd /tmp in install-google-chrome."
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb >> "$LOG" 2>&1
        # shellcheck disable=SC2024
        sudo dpkg -i google-chrome-stable_current_amd64.deb  >> "$LOG" 2>&1 || true
        # shellcheck disable=SC2024
        sudo apt -qq -f -y install >> "$LOG" 2>&1
        rm -f google-chrome-stable_current_amd64.deb
    fi
}

# Install geoip
function install-geoip() {
    if ! dpkg --status geoip-bin > /dev/null 2>&1 ; then
        info-message "Installing geoip."
        # shellcheck disable=SC2024
        sudo apt -y -qq install \
            geoip-bin \
            geoipupdate \
            mmdb-bin \
            python3-geoip \
            python3-pygeoip >> "$LOG" 2>&1
        info-message "Update geoip database."
        # shellcheck disable=SC2024
        sudo /usr/bin/geoipupdate >> "$LOG" 2>&1
    fi
}

function update-geoip() {
    info-message "Update geoip database."
    # shellcheck disable=SC2024
    sudo /usr/bin/geoipupdate >> "$LOG" 2>&1
}

# Create common directories
function create-common-directories(){
    info-message "Create basic directory structure."
    if [ ! -d ~/src ]; then
        mkdir -p ~/src/bin
    fi

    if [ ! -d ~/src/git ]; then
        mkdir -p ~/src/git
    fi

    if [ ! -d ~/src/python ]; then
        mkdir -p ~/src/python
    fi
}

# Create docker directories.
function create-docker-directories(){
    if [ ! -d ~/docker ]; then
        info-message "Create docker directory structure."
        mkdir -p ~/docker
    fi

    for dir in pescanner radare2 mastiff thug v8 viper; do
        if [ ! -d ~/docker/$dir ]; then
            mkdir ~/docker/$dir
            chmod 777 ~/docker/$dir
        fi
    done
}

# Create /cases/not-mounted
function create-cases-not-mounted(){
    if [[ ! -e /cases/not-mounted ]]; then
        # Check if already mounted
        if ! mount | grep /cases | grep ^.host > /dev/null ; then
            info-message "Create /cases/not-mounted."
            [[ ! -d /cases ]] && sudo mkdir /cases
            sudo chown "$USER" /cases
            touch /cases/not-mounted
        fi
    fi
}

# Fix problem with pip - https://github.com/pypa/pip/issues/1093
function fix-python-pip(){
    if [[ ! -e /usr/local/bin/pip ]]; then
        {
            sudo apt remove -yqq --auto-remove python-pip
            wget --quiet -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
            sudo -H python /tmp/get-pip.py
            sudo ln -s /usr/local/bin/pip /usr/bin/pip
            sudo rm /tmp/get-pip.py
            sudo -H pip install pyopenssl ndg-httpsclient pyasn1
            # shellcheck disable=SC2102
            sudo -H pip install --upgrade urllib3[secure]
        } >> "$LOG" 2>&1
        info-message "Install pip from pypa.io."
    fi
}

# Install moloch_query
function install-moloch_query(){
    info-message "Install moloch_query."
    if [ ! -d /data/moloch/bin ]; then
        error-message "Moloch not installed!"
        exit 1
    fi
    {
        wget -O /data/moloch/bin/moloch_query https://raw.githubusercontent.com/aol/moloch/master/contrib/moloch_query
        sudo apt -y -qq install python3-pip
        pip3 install requests elasticsearch
        sed -i -e r's/"query": {}/"query": {"match_all": {}}/' /data/moloch/bin/moloch_query
    } >> "$LOG" 2>&1
    info-message "Installed moloch_query."
}

# Install Volatility
# First argument should be target path to check out volatility.
function install-volatility() {
    VOLATILITY_PATH=$1
    if [[ $# -eq 0 ]]; then
        echo "One argument expected for install-volatility()"
        exit 1
    fi
    if [ -d "$VOLATILITY_PATH" ]; then
        echo "$VOLATILITY_PATH already exists!"
        exit 1
    fi
    info-message "Install volatility to $VOLATILITY_PATH."
    git clone --quiet https://github.com/volatilityfoundation/volatility "$VOLATILITY_PATH"
    cd "$VOLATILITY_PATH" || exit "Could not cd $VOLATILITY_PATH in install-volatility."
    pip install \
        Pillow \
        distorm3 \
        openpyxl \
        pycrypto \
        ujson \
        yara-python
    python setup.py install
}

function update-volatility(){
    VOLATILITY_PATH=$1
    if [[ -d "$VOLATILITY_PATH" ]]; then
        cd "$VOLATILITY_PATH" || exit "Couldn't cd $VOLATILITY_PATH in update-volatility."
        info-message "Update volatility in $VOLATILITY_PATH."
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade \
                Pillow \
                distorm3 \
                openpyxl \
                pycrypto \
                ujson \
                yara-python
            python setup.py install
        } >> "$LOG" 2>&1
    fi
}

# This repo contians newer versions of Wireshark etc. Update again after adding
function install-pi-rho-security(){
    if [[ ! -e /etc/apt/sources.list.d/pi-rho-security-trusty.list ]]; then
        info-message "Enable ppa:pi-rho/security and install updated packages."
        {
            sudo add-apt-repository -y ppa:pi-rho/security
            sudo apt -qq update
            while ! sudo apt -y dist-upgrade --force-yes ; do
                echo "APT busy. Will retry in 10 seconds."
                sleep 10
            done
            sudo apt -qq -y install html2text nasm
            sudo apt autoremove -qq -y
        } >> "$LOG" 2>&1
    fi
}

# Cleanup functions
function cleanup-remnux(){
    if [[ -e ~/examples.desktop ]]; then
        info-message "Clean up folders and files."
        rm -f ~/examples.desktop
    fi
    if [[ -e ~/Desktop/REMnux\ Cheat\ Sheet ]]; then
        info-message "Clean Desktop."
        [ ! -d ~/Documents/Remnux ] && mkdir -p ~/Documents/Remnux
        [ -e ~/Desktop/REMnux\ Docs ] && mv -f ~/Desktop/REMnux\ Docs  ~/Documents/Remnux/
        [ -e ~/Desktop/REMnux\ Tools\ Sheet ] && mv -f ~/Desktop/REMnux\ Tools\ Sheet  ~/Documents/Remnux/
        [ -e ~/Desktop/REMnux\ Cheat\ Sheet ] && mv -f ~/Desktop/REMnux\ Cheat\ Sheet  ~/Documents/Remnux/
        if [[ ! -e ~/Desktop/cases ]]; then
            ln -s /cases ~/Desktop/cases || true
        fi
        if [[ ! -e ~/Desktop/Remnux ]]; then
            ln -s ~/Documents/Remnux ~/Desktop/Remnux || true
        fi
    fi
}

function cleanup-sift(){
    if [[ -e ~/examples.desktop ]]; then
        info-message "Clean up folders and files."
        rm -f ~/examples.desktop
    fi
    if [[ -e ~/Desktop/SANS-DFIR.pdf ]]; then
        info-message "Clean Desktop."
        [ ! -d ~/Documents/SIFT ] && mkdir -p ~/Documents/SIFT
        sudo chown malware:malware ~/Desktop
        sudo chown malware:malware  ~/Desktop/*.pdf
        mv ~/Desktop/*.pdf ~/Documents/SIFT/ || true
        [ ! -e ~/Desktop/SIFT ] && ln -s ~/Documents/SIFT ~/Desktop/SIFT
    fi
}

function cleanup-moloch(){
    if [[ -e ~/examples.desktop ]]; then
        info-message "Clean up folders and files."
        rm -f ~/examples.desktop
        rm -f ~/moloch_*
    fi
}

function remove-old(){
    # Fixes from https://github.com/sans-dfir/sift/issues/106#issuecomment-251566412
    if [[ -e /etc/apt/sources.list.d/google-chrome.list ]]; then
        info-message "Remove old versions of Chrome."
        sudo rm -f /etc/apt/sources.list.d/google-chrome.list*
    fi

    # Remove old wireshark. Caused errors during update
    # shellcheck disable=SC2024
    if dpkg -l wireshark | grep 1.12 >> "$LOG" 2>&1 ; then
        info-message "Remove old versions of wireshark."
        sudo apt -y -qq remove wireshark >> "$LOG" 2>&1
    fi
}

# Install single file scripts

# https://github.com/sysforensics/VirusTotal
function install-VirusTotal(){
    echo "install-VirusTotal" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/vt_public.py && ! -e ~/src/bin/vt_public_autorun.py ]]; then
        wget -q -O ~/src/bin/vt_public.py \
            https://raw.githubusercontent.com/sysforensics/VirusTotal/master/vt_public.py >> "$LOG" 2>&1
        wget -q -O ~/src/bin/vt_public_autorun.py \
            https://raw.githubusercontent.com/sysforensics/VirusTotal/master/vt_public_autorun.py >> "$LOG" 2>&1
        chmod +x ~/src/bin/vt_public.py
        chmod +x ~/src/bin/vt_public_autorun.py
        info-message "Installed VirusTotal from sysforensics."
    fi
}

function update-VirusTotal(){
    info-message "Update VirusTotal."
    rm -f ~/src/bin/vt_public.py
    rm -f ~/src/bin/vt_public_autorun.py
    install-VirusTotal
}

# https://www.virustotal.com/en/documentation/public-api/#getting-file-scans
function install-vt-py(){
    echo "install-vt-py" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/vt.py ]]; then
        wget -q -O ~/src/bin/vt.py \
            https://raw.githubusercontent.com/Xen0ph0n/VirusTotal_API_Tool/master/vt.py >> "$LOG" 2>&1
        chmod +x ~/src/bin/vt.py
        info-message "Installed vt.py."
    fi
}

function update-vt-py(){
    info-message "Update vt.py."
    rm -f ~/src/bin/vt.py
    install-vt-py
}

# https://testssl.sh/
function install-testssl(){
    echo "install-testssl" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/testssl.sh ]]; then
        wget -q -O ~/src/bin/testssl.sh \
            https://testssl.sh/testssl.sh >> "$LOG" 2>&1
        chmod +x ~/src/bin/testssl.sh
        info-message "Installed testssl.sh."
    fi
}

function update-testssl(){
    info-message "Update testssl.sh."
    rm -f ~/src/bin/testssl.sh
    install-testssl
}

# Fireeye floss
function install-floss(){
    echo "install-floss" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/floss ]]; then
        wget -q -O ~/src/bin/floss \
            https://s3.amazonaws.com/build-artifacts.floss.flare.fireeye.com/travis/linux/dist/floss >> "$LOG" 2>&1
        chmod +x ~/src/bin/floss
        info-message "Installed floss."
    fi
}

function update-floss(){
    info-message "Update floss."
    rm -f ~/src/bin/floss
    install-floss
}

#https://github.com/decalage2/ViperMonkey
function install-ViperMonkey(){
    echo "install-ViperMonkey" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/ViperMonkey ]]; then
        git clone --quiet https://github.com/decalage2/ViperMonkey.git \
            ~/src/python/ViperMonkey >> "$LOG" 2>&1
        cd ~/src/python/ViperMonkey || exit "Couldn't cd into install-ViperMonkey."
        mkvirtualenv ViperMonkey >> "$LOG" 2>&1 || true
        {
            setvirtualenvproject
            pip install --upgrade pip
            pip install -U -r requirements.txt
        } >> "$LOG" 2>&1
        deactivate
        info-message "Checked out ViperMonkey."
    fi
}

function update-ViperMonkey(){
    if [[ -d ~/src/python/ViperMonkey ]]; then
        workon ViperMonkey || true
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade pip
        } >> "$LOG" 2>&1
        deactivate
        info-message "Updated ViperMonkey."
    fi
}

# https://github.com/secrary/SSMA
function install-SSMA(){
    echo "install-SSMA" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/SSMA ]]; then
        git clone --quiet https://github.com/secrary/SSMA.git \
            ~/src/python/SSMA >> "$LOG" 2>&1
        # Make virtualenv to install virtualenv...
        # Bug in old versions of virtualenv forces us to do this.
        mkvirtualenv venv >> "$LOG" 2>&1 || true
        pip install virtualenv
        virtualenv -p python3 ~/src/python/SSMA-env
        deactivate
        cd ~/src/python/SSMA || exit "Couldn't cd into install-SSMA."
        {
            # shellcheck disable=SC1090
            . ~/src/python/SSMA-env/bin/activate
            pip3 install -r requirements_with_ssdeep.txt
        } >> "$LOG" 2>&1
        deactivate
        info-message "Checked out SSMA."
    fi
}

function update-SSMA(){
    if [[ -d ~/src/python/SSMA ]]; then
        cd ~/src/python/SSMA || exit "Couldn't cd into install-SSMA."
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        # shellcheck disable=SC1090
        . ~/src/python/SSMA-env/bin/activate
        pip3 install --upgrade -r requirements_with_ssdeep.txt >> "$LOG" 2>&1
        deactivate
        info-message "Updated RecuperaBit."
    fi
}

# https://github.com/Lazza/RecuperaBit
function install-RecuperaBit(){
    echo "install-RecuperaBit" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/RecuperaBit ]]; then
        git clone --quiet https://github.com/Lazza/RecuperaBit.git \
            ~/src/python/RecuperaBit >> "$LOG" 2>&1
        cd ~/src/python/RecuperaBit || exit "Couldn't cd into install-RecuperaBit."
        mkvirtualenv RecuperaBit >> "$LOG" 2>&1 || true
        {
            setvirtualenvproject
            pip install --upgrade pip
            # shellcheck disable=SC2102
            pip install --upgrade urllib3[secure]
        } >> "$LOG" 2>&1
        deactivate
        info-message "Checked out RecuperaBit."
    fi
}

function update-RecuperaBit(){
    if [[ -d ~/src/python/RecuperaBit ]]; then
        workon RecuperaBit || true
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade pip
            # shellcheck disable=SC2102
            pip install --upgrade urllib3[secure]
        } >> "$LOG" 2>&1
        deactivate
        info-message "Updated RecuperaBit."
    fi
}

# https://github.com/MarkBaggett/srum-dump
function install-srum-dump(){
    echo "install-srum-dump" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/srum-dump ]]; then
        git clone --quiet https://github.com/MarkBaggett/srum-dump.git \
            ~/src/python/srum-dump >> "$LOG" 2>&1
        cd ~/src/python/srum-dump || exit "Couldn't cd into install-srum-dump."
        mkvirtualenv srum-dump >> "$LOG" 2>&1 || true
        {
            setvirtualenvproject
            pip install --upgrade pip
            # shellcheck disable=SC2102
            pip install --upgrade urllib3[secure]
            pip install impacket openpyxl python-registry
        } >> "$LOG" 2>&1
        deactivate
        info-message "Checked out srum-dump."
    fi
}

function update-srum-dump(){
    if [[ -d ~/src/python/srum-dump ]]; then
        workon srum-dump || true
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        pip install --upgrade pip
        # shellcheck disable=SC2102
        pip install --upgrade urllib3[secure]
        pip install --upgrade impacket openpyxl python-registry
        deactivate
        info-message "Updated srum-dump."
    fi
}

# https://github.com/x0rz/tweets_analyzer
function install-tweets_analyzer(){
    echo "install-tweets_analyzer" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/tweets_analyzer ]]; then
        git clone --quiet https://github.com/x0rz/tweets_analyzer.git \
            ~/src/python/tweets_analyzer >> "$LOG" 2>&1
        cd ~/src/python/tweets_analyzer || exit "Couldn't cd into install-tweets_analyzer."
        mkvirtualenv tweets_analyzer >> "$LOG" 2>&1 || true
        {
            setvirtualenvproject
            pip install --upgrade pip
            # shellcheck disable=SC2102
            pip install --upgrade urllib3[secure]
            pip install -r requirements.txt
        } >> "$LOG" 2>&1
        deactivate
        info-message "Checked out tweets_analyzer."
    fi
}

function update-tweets_analyzer(){
    if [[ -d ~/src/python/tweets_analyzer ]]; then
        workon tweets_analyzer || true
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        deactivate
        info-message "Updated tweets_analyzer."
    fi
}

# http://www.tekdefense.com/automater/
function install-automater(){
    echo "install-automater" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/automater ]]; then
        git clone --quiet https://github.com/1aN0rmus/TekDefense-Automater.git \
            ~/src/python/automater >> "$LOG" 2>&1
        cd ~/src/python/automater || exit "Couldn't cd into install-automater."
        mkvirtualenv automater >> "$LOG" 2>&1 || true
        setvirtualenvproject >> "$LOG" 2>&1
        deactivate
        info-message "Checked out Automater."
    fi
}

function update-automater(){
    if [[ -d ~/src/python/automater ]]; then
        workon automater || true
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        deactivate
        info-message "Updated Automater."
    fi
}

# https://n0where.net/malware-analysis-damm/
# Also install a seperate version of the latest volatility in this env.
function install-damm(){
    echo "install-damm" >> "$LOG" 2>&1
    # shellcheck disable=SC2102
    if [[ ! -d ~/src/python/damm ]]; then
        mkdir -p ~/src/python/damm
        git clone --quiet https://github.com/504ensicsLabs/DAMM \
            ~/src/python/damm/damm >> "$LOG" 2>&1
        cd ~/src/python/damm/damm || exit "Couldn't cd into install-damm."
        {
            mkvirtualenv damm || true
            setvirtualenvproject
            pip install --upgrade pip
            pip install --upgrade urllib3[secure]
            install-volatility ~/src/python/damm/volatility]
        } >> "$LOG" 2>&1
        deactivate
        info-message "Checked out DAMM."
    fi
}

function update-damm(){
    if [[ -d ~/src/python/damm ]]; then
        workon damm || true
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade pip
        } >> "$LOG" 2>&1
        update-volatility ~/src/python/damm/volatility
        deactivate
        info-message "Updated DAMM."
    fi
}

# Install Volutility
function install-volutility(){
    echo "install-volutility" >> "$LOG" 2>&1
    # shellcheck disable=SC2102
    if [[ ! -d ~/src/python/volutility ]]; then
        mkdir -p ~/src/python/volutility
        mkvirtualenv volutility >> "$LOG" 2>&1 || true
        echo "Start MongoDB with docker-mongodb" > ~/src/python/volutility/README
        {
            pip install --upgrade pip
            pip install --upgrade urllib3[secure]
            install-volatility ~/src/python/volutility/volatility
            git clone https://github.com/kevthehermit/VolUtility \
                ~/src/python/volutility/volutility
        } >> "$LOG" 2>&1
        cd ~/src/python/volutility/volutility || exit "Couldn't cd into install-volutility."
        pip install -r requirements.txt >> "$LOG" 2>&1
        pip install virustotal-api yara-python >> "$LOG" 2>&1
        deactivate
        info-message "Installed Volutility."
    fi
}

function update-volutility(){
    if [[ -d ~/src/python/volutility ]]; then
        workon volutility || true
        pip install --upgrade pip >> "$LOG" 2>&1
        update-volatility ~/src/python/volutility/volatility >> "$LOG" 2>&1
        cd ~/src/python/volutility/volutility || exit "Couldn't cd into update-volutility."
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade -r requirements.txt
            pip install --upgrade virustotal-api yara-python
        } >> "$LOG" 2>&1
        deactivate
        info-message "Updated Volutility."
    fi
}

# Keep a seperate environment for volatility (to be able to upgrade separatly)
function install-volatility-env(){
    echo "install-volatility-env" >> "$LOG" 2>&1
    # shellcheck disable=SC2102
    if [[ ! -d ~/src/python/volatility ]]; then
        mkdir -p ~/src/python/volatility
        {
            mkvirtualenv volatility || true
            pip install --upgrade pip
            pip install --upgrade urllib3[secure]
            install-volatility ~/src/python/volatility/volatility
        } >> "$LOG" 2>&1
        deactivate
        info-message "Checked out Volatility."
    fi
}

function update-volatility-env(){
    if [[ -d ~/src/python/volatility ]]; then
        workon volatility || true
        cd ~/src/python/volatility || exit "Couldn't cd into update-volatility-env."
        update-volatility ~/src/python/volatility/volatility
        deactivate
        info-message "Updated Volatility."
    fi
}

# https://github.com/DidierStevens/DidierStevensSuite
function install-didierstevenssuite(){
    echo "install-didierstevenssuite" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/didierstevenssuite ]]; then
        {
            git clone --quiet https://github.com/DidierStevens/DidierStevensSuite.git \
                ~/src/python/didierstevenssuite
            mkvirtualenv didierstevenssuite || true
            setvirtualenvproject
        } >> "$LOG" 2>&1
        enable-new-didier
        deactivate
        info-message "Checked out DidierStevensSuite."
    fi
}

function update-didierstevenssuite(){
    if [[ -d ~/src/python/didierstevenssuite ]]; then
        workon didierstevenssuite || true
        cd ~/src/python/didierstevenssuite || exit "Couldn't cd into update-didierstevenssuite."
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        enable-new-didier
        deactivate
        info-message "Updated DidierStevensSuite."
    fi
}

# https://github.com/decalage2/oletools.git
function install-oletools(){
    echo "install-oletools" >> "$LOG" 2>&1
    # shellcheck disable=SC2102
    if [[ ! -d ~/.virtualenvs/oletools ]]; then
        {
            mkvirtualenv oletools || true
            pip install --upgrade pip
            pip install --upgrade urllib3[secure]
            pip install oletools
        } >> "$LOG" 2>&1
        info-message "Installed oletools."
    fi
}

function update-oletools(){
    if [[ -d ~/.virtualenvs/oletools ]]; then
        workon oletools || true
        pip install --upgrade pip >> "$LOG" 2>&1
        pip install --upgrade oletools >> "$LOG" 2>&1
        info-message "Updated oletools."
    fi
}

# Rekall
function install-rekall(){
    echo "install-rekall" >> "$LOG" 2>&1
    if [[ ! -d ~/.virtualenvs/rekall ]]; then
        {
            mkvirtualenv rekall || true
            pip install --upgrade pip setuptools wheel
            pip install rekall-agent rekall
        } >> "$LOG" 2>&1
        deactivate
        info-message "Installed rekall."
    fi
}

function update-rekall(){
    if [[ -d ~/.virtualenvs/rekall ]]; then
        info-message "Remove current rekall."
        rm -rf ~/.virtualenvs/rekall
        install-rekall >> "$LOG" 2>&1
        info-message "Reinstalled rekall."
    fi
}

# https://github.com/bontchev/pcodedmp
function install-pcodedmp(){
    echo "install-pcodedmp" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/pcodedmp ]]; then
        {
            git clone --quiet https://github.com/bontchev/pcodedmp.git \
                ~/src/python/pcodedmp
            mkvirtualenv pcodedmp || true
            pip install --upgrade pip setuptools
            pip install oletools
        } >> "$LOG" 2>&1
        deactivate
        info-message "Installed pcodedmp."
    fi
}

function update-pcodedmp(){
    if [[ -d ~/src/python/pcodedmp ]]; then
        workon pcodedmp || true
        cd ~/src/python/pcodedmp || exit "Couldn't cd into update-pcodedmp."
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        deactivate
        info-message "Updated pcodedmp."
    fi
}

# https://github.com/ChrisTruncer/Just-Metadata
function install-just-metadata(){
    echo "install-just-metadata" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/just-metadata ]]; then
        {
            git clone --quiet https://github.com/ChrisTruncer/Just-Metadata.git \
                ~/src/python/just-metadata
            mkvirtualenv just-metadata || true
            pip install --upgrade pip setuptools
            pip install ipwhois requests shodan netaddr
        } >> "$LOG" 2>&1
        deactivate
        info-message "Installed just-metadata."
    fi
}

function update-just-metadata(){
    if [[ -d ~/src/python/just-metadata ]]; then
        workon just-metadata || true
        cd ~/src/python/just-metadata || exit "Couldn't cd into update-just-metadata."
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade pip setuptools
            pip install --upgrade ipwhois requests shodan netaddr
        } >> "$LOG" 2>&1
        deactivate
        info-message "Updated just-metadata."
    fi
}

# https://github.com/keydet89/RegRipper2.8
function install-regripper(){
    echo "install-regripper" >> "$LOG" 2>&1
    if [[ ! -d ~/src/git/RegRipper2.8 ]]; then
        git clone --quiet https://github.com/keydet89/RegRipper2.8.git \
            ~/src/git/RegRipper2.8 >> "$LOG" 2>&1
        info-message "Checked out RegRipper2.8."
        ln -s ~/remnux-tools/files/regripper2.8 ~/src/bin/regripper2.8
        chmod 755 ~/remnux-tools/files/regripper2.8
    fi
}

# https://github.com/nationalsecurityagency/dcp
function install-dcp(){
    echo "install-dcp" >> "$LOG" 2>&1
    if [[ ! -d ~/src/git/dcp ]]; then
        git clone --quiet https://github.com/NationalSecurityAgency/DCP.git \
            ~/src/git/dcp >> "$LOG" 2>&1
        # shellcheck disable=SC2024
        sudo apt install -yqq gengetopt autoconf libtool libjansson-dev \
            libdb-dev >> "$LOG" 2>&1
        cd ~/src/git/dcp || echo "Couldn't cd to dcp."
        {
            ./bootstrap.sh
            ./configure
            make
            sudo make install
            make clean
        } >> "$LOG" 2>&1
        info-message "Installed DCP."
    fi
}

function update-dcp(){
    echo "update-dcp" >> "$LOG" 2>&1
    if [[ -d ~/src/git/dcp ]]; then
        cd ~/src/git/dcp || echo "Couldn't cd to dcp."
        {
            make clean
            git fetch --all
            git reset --hard origin/master
            git pull
            ./bootstrap.sh
            ./configure
            make
            sudo make install
            make clean
        } >> "$LOG" 2>&1
        info-message "Updated DCP."
    fi
}

# Checkout git repo to directory
function checkout-git-repo(){
    echo "Checkout $2 to $1" >> "$LOG" 2>&1
    if [[ ! -d ~/src/git/"$2" ]]; then
        git clone --quiet "$1" ~/src/git/"$2" >> "$LOG" 2>&1
        info-message "Checkout git repo $1"
    fi
}

# Update git repositories
function update-git-repositories(){
    cd ~/src/git || exit 1
    info-message "Update git repositories."
    for repo in *; do
        info-message "Updating $repo."
        (cd "$repo" || exit "Couldn't cd into update-git-repositories" ; git fetch --all >> "$LOG" 2>&1; git reset --hard origin/master >> "$LOG" 2>&1)
    done
    info-message "Updated git repositories."
}

# https://github.com/radare/radare2
function install-radare2(){
    echo "install-radare2" >> "$LOG" 2>&1
    # shellcheck disable=SC2024
    if [[ ! -d ~/src/git/radare2 ]]; then
        info-message "Starting installation of radare2."
        sudo apt remove -y radare2 >> "$LOG" 2>&1
        sudo apt autoremove -y >> "$LOG" 2>&1
        checkout-git-repo https://github.com/radare/radare2.git radare2
        cd ~/src/git/radare2 || exit "Couldn't cd into install-radare2."
        make clean >> "$LOG" 2>&1 || true
        ./sys/install.sh >> "$LOG" 2>&1 || error-message "./sys/install.sh failed!"
        info-message "Installed radare2."
    fi
}

function update-radare2(){
    echo "update-radare2" >> "$LOG" 2>&1
    # shellcheck disable=SC2024
    if [[ -d ~/src/git/radare2 ]]; then
        sudo apt remove -y radare2 >> "$LOG" 2>&1
        sudo apt autoremove -y >> "$LOG" 2>&1
        cd ~/src/git/radare2 || exit "Couldn't cd into update-radare2."
        {
            git fetch --all
            git reset --hard origin/master
            ./sys/install.sh
        } >> "$LOG" 2>&1
        info-message "Updated radare2."
    fi
}

# Main install and update functions
# REMnux
function install-remnux(){
    if [[ ! -e ~/.config/.remnux ]]; then
        info-message "Start installation of Remnux."
        wget --quiet -O - https://remnux.org/get-remnux.sh | sudo bash
        touch ~/.config/.remnux
        info-message "Remnux installation finished."
    fi
}

# SIFT
function install-sift(){
    if [[ ! -e ~/.config/.sift ]]; then
        info-message "Start installation of SIFT."
        cd /tmp || true
        {
            sudo apt remove -y python3-xlsxwriter
            sudo apt autoremove -y
            wget "$(curl -s https://api.github.com/repos/sans-dfir/sift-cli/releases/latest | \
                grep 'browser_' | cut -d\" -f4 | head -1)"
            wget "$(curl -s https://api.github.com/repos/sans-dfir/sift-cli/releases/latest | \
                grep 'browser_' | cut -d\" -f4 | tail -1)"
        } >> "$LOG" 2>&1
        # Does not validate gpg at the moment due to problems downloading keys in some networks...
        chmod +x /tmp/sift-cli-linux
        sudo mv /tmp/sift-cli-linux /usr/local/bin/sift
        rm -f /tmp/sift-cli-linux.sha256.asc
        # shellcheck disable=SC2024
        sudo /usr/local/bin/sift install >> "$LOG" 2>&1
        touch ~/.config/.sift
        info-message "SITF installation finished."
    fi
}

function update-sift(){
    START_FRESHCLAM=1
    info-message "Start SITF upgrade."
    # shellcheck disable=SC2024
    if ! sudo service clamav-freshclam status >> "$LOG" 2>&1 ; then
        # shellcheck disable=SC2024
        sudo service clamav-freshclam stop >> "$LOG" 2>&1
        START_FRESHCLAM=0
    fi
    {
        # shellcheck disable=SC2024
        sudo /usr/local/bin/sift update || true
        # shellcheck disable=SC2024
        sudo /usr/local/bin/sift upgrade
        # Run upgrade twice since I often seen some fails the first time
        # shellcheck disable=SC2024
        sudo /usr/local/bin/sift upgrade
    } >> "$LOG" 2>&1
    info-message "SITF upgrade finished."
    if [[ $START_FRESHCLAM -eq 0 ]]; then
        # shellcheck disable=SC2024
        sudo service clamav-freshclam start >> "$LOG" 2>&1
    fi
}

# Moloch
function install-moloch(){
    if [[ ! -e ~/.config/.moloch ]]; then
        info-message "Start installation of Moloch."
        {
            DEBIAN_FRONTEND=noninteractive apt -y -qq install \
                default-jre
            wget --quiet https://files.molo.ch/builds/ubuntu-18.04/moloch_1.6.1-1_amd64.deb
            dpkg --install moloch_1.6.1-1_amd64.deb || true
            apt -y --fix-broken install
        } >> "$LOG" 2>&1

        info-message "Run Configure for Moloch"
        MOLOCH_INTERFACE=$(ip addr | grep ens | grep "state UP" | cut -f2 -d: | sed -e "s/ //g")
        MOLOCH_PASSWORD="password"
        export MOLOCH_INTERFACE MOLOCH_PASSWORD
        sudo sed -i -e "s/MOLOCH_LOCALELASTICSEARCH=not-set/MOLOCH_LOCALELASTICSEARCH=yes/" /data/moloch/bin/Configure
        sudo sed -i -e "s/MOLOCH_INET=not-set/MOLOCH_INET=yes/" /data/moloch/bin/Configure
        sudo -E /data/moloch/bin/Configure

        info-message "Start elasticsearch.service"
        sudo systemctl start elasticsearch.service
        sleep 30
        info-message "Init elasticsearch.service"
        echo "INIT" | /data/moloch/db/db.pl http://127.0.0.1:9200 init
        info-message "Add user to moloch"
        /data/moloch/bin/moloch_add_user.sh admin "Admin User" password --admin --email

        info-message "Create bin directory and add start-moloch.sh script."
        [ ! -d /home/malware/bin ] && mkdir -p /home/malware/bin
        cp /home/malware/remnux-tools/files/start-moloch.sh /home/malware/bin/start-moloch.sh
        chown malware:malware /home/malware/bin/start-moloch.sh

        [ ! -d /home/malware/.config ] && mkdir /home/malware/.config && chown malware:malware /home/malware/.config
        touch /home/malware/.config/.moloch
        info-message "Moloch installation finished."
    fi
}

function update-moloch(){
    info-message "Start Moloch upgrade."
    info-message "   ## NOTHING TODO ##"
    info-message "Moloch upgrade finished."
}
