#!/bin/bash

ARKIME_VERSION="5.7.0"

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

function error-exit-message() {
    (>&2 echo "**** ERROR: $*")
    exit 1
}

# Turn off sound on start up
function turn-off-sound() {
    if [[ ! -e /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override ]]; then
        echo "turn-off-sound" >> "$LOG" 2>&1
        echo -e '[com.canonical.unity-greeter]\nplay-ready-sound = false' |
            sudo tee -a /usr/share/glib-2.0/schemas/50_unity-greeter.gschema.override > /dev/null
        sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
    fi
}

function update-ubuntu() {
    info-message "Updating Ubuntu."
    info-message "Running apt update."
    # shellcheck disable=SC2024
    sudo apt update >> "$LOG" 2>&1
    info-message "Running apt dist-upgrade."
    # shellcheck disable=SC2024
    while ! sudo DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade --force-yes >> "$LOG" 2>&1; do
        echo "APT busy. Will retry in 10 seconds."
        sleep 10
    done
}

# General tools
function install-general-tools() {
    info-message "Installing general tools."
    # shellcheck disable=SC2024
    sudo DEBIAN_FRONTEND=noninteractive apt -y -qq install \
        ascii \
        bless \
        bsdgames \
        build-essential \
        curl \
        dos2unix \
        exfat-fuse \
        git \
        htop \
        jq \
        libffi-dev \
        libimage-exiftool-perl \
        libncurses5-dev \
        libssl-dev \
        p7zip \
        python3-dev \
        python3-virtualenv \
        screen \
        sharutils \
        sqlite3 \
        sqlitebrowser \
        strace \
        tmux \
        tshark \
        vim \
        vim-doc \
        vim-scripts \
        virtualenvwrapper \
        wget \
        whois \
        wswedish \
        zip >> "$LOG" 2>&1
    # shellcheck disable=SC2024
    sudo DEBIAN_FRONTEND=noninteractive apt -y -qq install \
        unrar >> "${LOG}" 2>&1 ||
        sudo DEBIAN_FRONTEND=noninteractive apt -y -qq install \
            unrar-free >> "${LOG}" 2>&1
}

# Tools for Vmware
function install-vmware-tools() {
    info-message "Installing tools for VMware."
    # shellcheck disable=SC2024
    sudo apt -y -qq install \
        open-vm-tools-desktop >> "$LOG" 2>&1
}

# Install Docker Community edition for the latest functions.
# Use the default install script since this is for test only.
function install-docker-ce() {
    info-message "Installing Docker Community Edition."
    {
        sudo apt -y -qq install curl python-pip
        cd || exit
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker malware
        sudo pip3 install docker-compose
        rm get-docker.sh
    } >> "$LOG" 2>&1
}

function install-apt-remnux() {
    info-message "Installing apt-packages for REMnux."
    # sleuthkit provides hfind(1)
    # shellcheck disable=SC2024
    sudo apt -y -qq install \
        mpack \
        sleuthkit \
        testdisk \
        tree >> "$LOG" 2>&1
}

function install-apt-arkime() {
    info-message "Installing apt-packages for Arkime."
    echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
    # shellcheck disable=SC2024
    DEBIAN_FRONTEND=noninteractive sudo apt -y -qq install \
        bash-completion \
        cifs-utils \
        docker.io \
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
    if [[ "$(uname -m)" == "aarch64" ]]; then
        if ! dpkg --status chromium > /dev/null 2>&1; then
            info-message "Installing chromium."
            # shellcheck disable=SC2024
            DEBIAN_FRONTEND=noninteractive sudo apt -y -qq install chromium >> "$LOG" 2>&1
        fi
    else
        if ! dpkg --status google-chrome-stable > /dev/null 2>&1; then
            info-message "Installing Google Chrome."
            cd /tmp || error-exit-message "Couldn't cd /tmp in install-google-chrome."
            wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb >> "$LOG" 2>&1
            # shellcheck disable=SC2024
            sudo dpkg -i google-chrome-stable_current_amd64.deb >> "$LOG" 2>&1 || true
            # shellcheck disable=SC2024
            sudo apt -qq -f -y install >> "$LOG" 2>&1
            rm -f google-chrome-stable_current_amd64.deb
        fi
    fi
}

# Install geoip
function install-geoip() {
    if ! dpkg --status geoip-bin > /dev/null 2>&1; then
        if test -e /etc/os-release && grep "Debian" /etc/os-release > /dev/null; then
            # shellcheck disable=SC2024
            DEBIAN_FRONTEND=noninteractive sudo apt install software-properties-common -y >> "$LOG" 2>&1
            # shellcheck disable=SC2024
            DEBIAN_FRONTEND=noninteractive sudo apt-add-repository -y contrib non-free-firmware >> "$LOG" 2>&1
        fi
        info-message "Installing geoip."
        # shellcheck disable=SC2024
        sudo apt -y -qq install \
            geoip-bin \
            geoipupdate \
            mmdb-bin \
            python3-geoip \
            python3-pygeoip >> "$LOG" 2>&1
        # Don't update due to new requirement for account login.
        info-message "Update geoip database."
        read -r -p "Update your Maxmind key. Click enter to open the configuration file in vim."
        sudo vim /etc/GeoIP.conf
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
function create-common-directories() {
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
function create-docker-directories() {
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
function create-cases-not-mounted() {
    if [[ ! -e /cases/not-mounted ]]; then
        # Check if already mounted
        if ! mount | grep /cases | grep ^.host > /dev/null; then
            info-message "Create /cases/not-mounted."
            [[ ! -d /cases ]] && sudo mkdir /cases
            sudo chown "$USER" /cases
            touch /cases/not-mounted
        fi
    fi
}

# Fix problem with pip - https://github.com/pypa/pip/issues/1093
function fix-python-pip() {
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
    cd "$VOLATILITY_PATH" || error-exit-message "Could not cd $VOLATILITY_PATH in install-volatility."
    pip install \
        Pillow \
        distorm3 \
        openpyxl \
        pycrypto \
        ujson \
        yara-python
    python setup.py install
}

function update-volatility() {
    VOLATILITY_PATH=$1
    if [[ -d "$VOLATILITY_PATH" ]]; then
        cd "$VOLATILITY_PATH" || error-exit-message "Couldn't cd $VOLATILITY_PATH in update-volatility."
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
function install-pi-rho-security() {
    if [[ ! -e /etc/apt/sources.list.d/pi-rho-security-trusty.list ]]; then
        info-message "Enable ppa:pi-rho/security and install updated packages."
        {
            sudo add-apt-repository -y ppa:pi-rho/security
            sudo apt -qq update
            while ! sudo apt -y dist-upgrade --force-yes; do
                echo "APT busy. Will retry in 10 seconds."
                sleep 10
            done
            sudo apt -qq -y install html2text nasm
            sudo apt-get autoremove -qq -y
        } >> "$LOG" 2>&1
    fi
}

# Cleanup functions
function cleanup-remnux() {
    if [[ -e ~/examples.desktop ]]; then
        info-message "Clean up folders and files."
        rm -f ~/examples.desktop
    fi
    if [[ -e ~/Desktop/REMnux\ Cheat\ Sheet ]]; then
        info-message "Clean Desktop."
        [ ! -d ~/Documents/Remnux ] && mkdir -p ~/Documents/Remnux
        [ -e ~/Desktop/REMnux\ Docs ] && mv -f ~/Desktop/REMnux\ Docs ~/Documents/Remnux/
        [ -e ~/Desktop/REMnux\ Tools\ Sheet ] && mv -f ~/Desktop/REMnux\ Tools\ Sheet ~/Documents/Remnux/
        [ -e ~/Desktop/REMnux\ Cheat\ Sheet ] && mv -f ~/Desktop/REMnux\ Cheat\ Sheet ~/Documents/Remnux/
        if [[ ! -e ~/Desktop/cases ]]; then
            ln -s /cases ~/Desktop/cases || true
        fi
        if [[ ! -e ~/Desktop/Remnux ]]; then
            ln -s ~/Documents/Remnux ~/Desktop/Remnux || true
        fi
    fi
}

function cleanup-sift() {
    if [[ -e ~/examples.desktop ]]; then
        info-message "Clean up folders and files."
        rm -f ~/examples.desktop
    fi
    if [[ -e ~/Desktop/SIFT-Cheatsheet.pdf ]]; then
        info-message "Clean Desktop."
        [ ! -d ~/Documents/SIFT ] && mkdir -p ~/Documents/SIFT
        sudo chown malware:malware ~/Desktop
        sudo chown malware:malware ~/Desktop/*.pdf
        mv ~/Desktop/*.pdf ~/Documents/SIFT/ || true
        [ ! -e ~/Desktop/SIFT ] && ln -s ~/Documents/SIFT ~/Desktop/SIFT
    fi
}

function cleanup-arkime() {
    if [[ -e ~/examples.desktop ]]; then
        info-message "Clean up folders and files."
        rm -f ~/examples.desktop
        rm -f ~/arkime*
    fi
}

function remove-old() {
    # Fixes from https://github.com/sans-dfir/sift/issues/106#issuecomment-251566412
    if [[ -e /etc/apt/sources.list.d/google-chrome.list ]]; then
        info-message "Remove old versions of Chrome."
        sudo rm -f /etc/apt/sources.list.d/google-chrome.list*
    fi

    # Remove old wireshark. Caused errors during update
    # shellcheck disable=SC2024
    if dpkg -l wireshark | grep 1.12 >> "$LOG" 2>&1; then
        info-message "Remove old versions of wireshark."
        sudo apt -y -qq remove wireshark >> "$LOG" 2>&1
    fi
}

# Install single file scripts

# https://github.com/sysforensics/VirusTotal
function install-VirusTotal() {
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

function update-VirusTotal() {
    info-message "Update VirusTotal."
    rm -f ~/src/bin/vt_public.py
    rm -f ~/src/bin/vt_public_autorun.py
    install-VirusTotal
}

# https://www.virustotal.com/en/documentation/public-api/#getting-file-scans
function install-vt-py() {
    echo "install-vt-py" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/vt.py ]]; then
        wget -q -O ~/src/bin/vt.py \
            https://raw.githubusercontent.com/Xen0ph0n/VirusTotal_API_Tool/master/vt.py >> "$LOG" 2>&1
        chmod +x ~/src/bin/vt.py
        info-message "Installed vt.py."
    fi
}

function update-vt-py() {
    info-message "Update vt.py."
    rm -f ~/src/bin/vt.py
    install-vt-py
}

# https://testssl.sh/
function install-testssl() {
    echo "install-testssl" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/testssl.sh ]]; then
        wget -q -O ~/src/bin/testssl.sh \
            https://testssl.sh/testssl.sh >> "$LOG" 2>&1
        chmod +x ~/src/bin/testssl.sh
        info-message "Installed testssl.sh."
    fi
}

function update-testssl() {
    info-message "Update testssl.sh."
    rm -f ~/src/bin/testssl.sh
    install-testssl
}

# https://github.com/brendangregg/Chaosreader
function install-chaosreader() {
    echo "install-chaosreader" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/chaosreader ]]; then
        wget -q -O ~/src/bin/chaosreader \
            https://raw.githubusercontent.com/brendangregg/Chaosreader/master/chaosreader >> "$LOG" 2>&1
        chmod +x ~/src/bin/chaosreader
        info-message "Installed chaosreader."
    fi
}

function update-chaosreader() {
    info-message "Update chaosreader."
    rm -f ~/src/bin/chaosreader
    install-chaosreader
}

# Fireeye floss
function install-floss() {
    echo "install-floss" >> "$LOG" 2>&1
    if [[ ! -e ~/src/bin/floss ]]; then
        wget -q -O ~/src/bin/floss \
            https://s3.amazonaws.com/build-artifacts.floss.flare.fireeye.com/travis/linux/dist/floss >> "$LOG" 2>&1
        chmod +x ~/src/bin/floss
        info-message "Installed floss."
    fi
}

function update-floss() {
    info-message "Update floss."
    rm -f ~/src/bin/floss
    install-floss
}

# Brim
function install-brim() {
    info-message "Start installation of Brim."
    cd /tmp || true
    wget "$(curl -s https://api.github.com/repos/brimdata/brim/releases/latest | jq '' |
        grep 'browser_' | grep -E "/Brim-.*\.deb" | cut -d\" -f4 | head -1)" >> "$LOG" 2>&1
    sudo dpkg -i Brim*.deb
    rm -f Brim*.deb
    info-message "Installed Brim."
}

function update-brim() {
    info-message "Start update of Brim."
    cd /tmp || true
    wget "$(curl -s https://api.github.com/repos/brimdata/brim/releases/latest | jq '' |
        grep 'browser_' | grep -E "/Brim-.*\.deb" | cut -d\" -f4 | head -1)" >> "$LOG" 2>&1
    sudo dpkg -i Brim*.deb
    rm -f Brim*.deb
    info-message "Brim updated."
}

# https://github.com/Lazza/RecuperaBit
function install-RecuperaBit() {
    echo "install-RecuperaBit" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/RecuperaBit ]]; then
        git clone --quiet https://github.com/Lazza/RecuperaBit.git \
            ~/src/python/RecuperaBit >> "$LOG" 2>&1
        cd ~/src/python/RecuperaBit || error-exit-message "Couldn't cd into install-RecuperaBit."
        mkvirtualenv RecuperaBit >> "$LOG" 2>&1 || true
        {
            setvirtualenvproject
            pip install --upgrade pip
            # shellcheck disable=SC2102
            pip install --upgrade urllib3[secure]
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Checked out RecuperaBit."
    fi
}

function update-RecuperaBit() {
    if [[ -d ~/src/python/RecuperaBit ]]; then
        workon RecuperaBit || true
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade pip
            # shellcheck disable=SC2102
            pip install --upgrade urllib3[secure]
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Updated RecuperaBit."
    fi
}

# https://github.com/MarkBaggett/srum-dump
function install-srum-dump() {
    echo "install-srum-dump" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/srum-dump ]]; then
        git clone --quiet https://github.com/MarkBaggett/srum-dump.git \
            ~/src/python/srum-dump >> "$LOG" 2>&1
        cd ~/src/python/srum-dump || error-exit-message "Couldn't cd into install-srum-dump."
        mkvirtualenv srum-dump >> "$LOG" 2>&1 || true
        {
            setvirtualenvproject
            pip install --upgrade pip
            # shellcheck disable=SC2102
            pip install --upgrade urllib3[secure]
            pip install impacket openpyxl python-registry
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Checked out srum-dump."
    fi
}

function update-srum-dump() {
    if [[ -d ~/src/python/srum-dump ]]; then
        workon srum-dump || true
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        pip install --upgrade pip
        # shellcheck disable=SC2102
        pip install --upgrade urllib3[secure]
        pip install --upgrade impacket openpyxl python-registry
        deactivate || true
        info-message "Updated srum-dump."
    fi
}

# http://www.tekdefense.com/automater/
function install-automater() {
    echo "install-automater" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/automater ]]; then
        git clone --quiet https://github.com/1aN0rmus/TekDefense-Automater.git \
            ~/src/python/automater >> "$LOG" 2>&1
        cd ~/src/python/automater || error-exit-message "Couldn't cd into install-automater."
        mkvirtualenv automater >> "$LOG" 2>&1 || true
        setvirtualenvproject >> "$LOG" 2>&1
        deactivate || true
        info-message "Checked out Automater."
    fi
}

function update-automater() {
    if [[ -d ~/src/python/automater ]]; then
        workon automater || true
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        deactivate || true
        info-message "Updated Automater."
    fi
}

# https://n0where.net/malware-analysis-damm/
# Also install a seperate version of the latest volatility in this env.
function install-damm() {
    echo "install-damm" >> "$LOG" 2>&1
    # shellcheck disable=SC2102
    if [[ ! -d ~/src/python/damm ]]; then
        mkdir -p ~/src/python/damm
        git clone --quiet https://github.com/504ensicsLabs/DAMM \
            ~/src/python/damm/damm >> "$LOG" 2>&1
        cd ~/src/python/damm/damm || error-exit-message "Couldn't cd into install-damm."
        {
            mkvirtualenv damm || true
            setvirtualenvproject
            pip install --upgrade pip
            pip install --upgrade urllib3[secure]
            install-volatility ~/src/python/damm/volatility]
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Checked out DAMM."
    fi
}

function update-damm() {
    if [[ -d ~/src/python/damm ]]; then
        workon damm || true
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade pip
        } >> "$LOG" 2>&1
        update-volatility ~/src/python/damm/volatility
        deactivate || true
        info-message "Updated DAMM."
    fi
}

# Keep a seperate environment for volatility (to be able to upgrade separatly)
function install-volatility-env() {
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
        deactivate || true
        info-message "Checked out Volatility."
    fi
}

function update-volatility-env() {
    if [[ -d ~/src/python/volatility ]]; then
        workon volatility || true
        cd ~/src/python/volatility || error-exit-message "Couldn't cd into update-volatility-env."
        update-volatility ~/src/python/volatility/volatility
        deactivate || true
        info-message "Updated Volatility."
    fi
}

# https://github.com/DidierStevens/DidierStevensSuite
function install-didierstevenssuite() {
    echo "install-didierstevenssuite" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/didierstevenssuite ]]; then
        {
            git clone --quiet https://github.com/DidierStevens/DidierStevensSuite.git \
                ~/src/python/didierstevenssuite
            mkvirtualenv didierstevenssuite || true
            setvirtualenvproject
        } >> "$LOG" 2>&1
        enable-new-didier
        deactivate || true
        info-message "Checked out DidierStevensSuite."
    fi
}

function update-didierstevenssuite() {
    if [[ -d ~/src/python/didierstevenssuite ]]; then
        workon didierstevenssuite || true
        cd ~/src/python/didierstevenssuite || error-exit-message "Couldn't cd into update-didierstevenssuite."
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        enable-new-didier
        deactivate || true
        info-message "Updated DidierStevensSuite."
    fi
}

# https://github.com/decalage2/oletools.git
function install-oletools() {
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

function update-oletools() {
    if [[ -d ~/.virtualenvs/oletools ]]; then
        workon oletools || true
        pip install --upgrade pip >> "$LOG" 2>&1
        pip install --upgrade oletools >> "$LOG" 2>&1
        info-message "Updated oletools."
    fi
}

# Rekall
function install-rekall() {
    echo "install-rekall" >> "$LOG" 2>&1
    if [[ ! -d ~/.virtualenvs/rekall ]]; then
        {
            mkvirtualenv rekall || true
            pip install --upgrade pip setuptools wheel
            pip install rekall-agent rekall
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Installed rekall."
    fi
}

function update-rekall() {
    if [[ -d ~/.virtualenvs/rekall ]]; then
        info-message "Remove current rekall."
        rm -rf ~/.virtualenvs/rekall
        install-rekall >> "$LOG" 2>&1
        info-message "Reinstalled rekall."
    fi
}

# https://github.com/bontchev/pcodedmp
function install-pcodedmp() {
    echo "install-pcodedmp" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/pcodedmp ]]; then
        {
            git clone --quiet https://github.com/bontchev/pcodedmp.git \
                ~/src/python/pcodedmp
            mkvirtualenv pcodedmp || true
            pip install --upgrade pip setuptools
            pip install oletools
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Installed pcodedmp."
    fi
}

function update-pcodedmp() {
    if [[ -d ~/src/python/pcodedmp ]]; then
        workon pcodedmp || true
        cd ~/src/python/pcodedmp || error-exit-message "Couldn't cd into update-pcodedmp."
        git fetch --all >> "$LOG" 2>&1
        git reset --hard origin/master >> "$LOG" 2>&1
        deactivate || true
        info-message "Updated pcodedmp."
    fi
}

# https://github.com/ChrisTruncer/Just-Metadata
function install-just-metadata() {
    echo "install-just-metadata" >> "$LOG" 2>&1
    if [[ ! -d ~/src/python/just-metadata ]]; then
        {
            git clone --quiet https://github.com/ChrisTruncer/Just-Metadata.git \
                ~/src/python/just-metadata
            mkvirtualenv just-metadata || true
            pip install --upgrade pip setuptools
            pip install ipwhois requests shodan netaddr
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Installed just-metadata."
    fi
}

function update-just-metadata() {
    if [[ -d ~/src/python/just-metadata ]]; then
        workon just-metadata || true
        cd ~/src/python/just-metadata || error-exit-message "Couldn't cd into update-just-metadata."
        {
            git fetch --all
            git reset --hard origin/master
            pip install --upgrade pip setuptools
            pip install --upgrade ipwhois requests shodan netaddr
        } >> "$LOG" 2>&1
        deactivate || true
        info-message "Updated just-metadata."
    fi
}

# https://github.com/keydet89/RegRipper4.0
function install-regripper() {
    echo "install-regripper" >> "$LOG" 2>&1
    if [[ ! -d ~/src/git/RegRipper4.0 ]]; then
        git clone --quiet https://github.com/keydet89/RegRipper4.0.git \
            ~/src/git/RegRipper4.0 >> "$LOG" 2>&1
        info-message "Checked out RegRipper4.0."
        ln -s ~/remnux-tools/files/regripper ~/src/bin/regripper
        chmod 755 ~/remnux-tools/files/regripper
    fi
}

# https://github.com/nationalsecurityagency/dcp
function install-dcp() {
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

function update-dcp() {
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
function checkout-git-repo() {
    echo "Checkout $2 to $1" >> "$LOG" 2>&1
    if [[ ! -d ~/src/git/"$2" ]]; then
        git clone --quiet "$1" ~/src/git/"$2" >> "$LOG" 2>&1
        info-message "Checkout git repo $1"
    fi
}

# Update git repositories
function update-git-repositories() {
    cd ~/src/git || exit 1
    info-message "Update git repositories."
    shopt -s nullglob
    for repo in *; do
        info-message "Updating $repo."
        (
            cd "$repo" || error-exit-message "Couldn't cd into update-git-repositories"
            git fetch --all >> "$LOG" 2>&1
            git reset --hard origin/master >> "$LOG" 2>&1
        )
    done
    info-message "Updated git repositories."
}

# https://github.com/radare/radare2
function install-radare2() {
    echo "install-radare2" >> "$LOG" 2>&1
    # shellcheck disable=SC2024
    if [[ ! -d ~/src/git/radare2 ]]; then
        info-message "Starting installation of radare2."
        sudo apt remove -y radare2 >> "$LOG" 2>&1
        sudo apt-get autoremove -y >> "$LOG" 2>&1
        checkout-git-repo https://github.com/radare/radare2.git radare2
        cd ~/src/git/radare2 || error-exit-message "Couldn't cd into install-radare2."
        make clean >> "$LOG" 2>&1 || true
        ./sys/install.sh >> "$LOG" 2>&1 || error-message "./sys/install.sh failed!"
        info-message "Installed radare2."
    fi
}

function update-radare2() {
    echo "update-radare2" >> "$LOG" 2>&1
    # shellcheck disable=SC2024
    if [[ -d ~/src/git/radare2 ]]; then
        sudo apt remove -y radare2 >> "$LOG" 2>&1
        sudo apt-get autoremove -y >> "$LOG" 2>&1
        cd ~/src/git/radare2 || error-exit-message "Couldn't cd into update-radare2."
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
function install-remnux() {
    if [[ ! -e ~/.config/.remnux ]]; then
        info-message "Start installation of Remnux."
        rm -f remnux-cli
        wget --quiet https://REMnux.org/remnux-cli
        mv remnux-cli remnux
        chmod +x remnux
        sudo mv remnux /usr/local/bin
        sudo apt install -y gnupg
        sudo systemctl stop ssh.service
        sudo /usr/local/bin/remnux install
        sudo systemctl start ssh.service
        touch ~/.config/.remnux
        info-message "Remnux installation finished."
    fi
}

# SIFT
function install-sift() {
    if [[ ! -e ~/.config/.sift ]]; then
        info-message "Start installation of SIFT."
        cd /tmp || true
        {
            sudo apt-get autoremove -y
            if [[ $(uname -m) == "x86_64" ]]; then
                ARCH="amd64"
            else
                ARCH="arm64"
            fi
            wget "$(curl -s https://api.github.com/repos/ekristen/cast/releases/latest | jq '' |
                grep 'browser_' | grep deb | grep -v deb.sig | grep "$ARCH" | cut -d\" -f4 | head -1)"
            wget "$(curl -s https://api.github.com/repos/ekristen/cast/releases/latest | jq '' |
                grep 'browser_' | grep deb | grep -v deb.sig | grep "$ARCH" | cut -d\" -f4 | tail -1)"
        } >> "$LOG" 2>&1
        # Does not validate gpg at the moment due to problems downloading keys in some networks...
        sudo dpkg -i cast*.deb
        sudo systemctl stop ssh.service
        # shellcheck disable=SC2024
        sudo /usr/bin/cast install teamdfir/sift-saltstack 2>&1 | tee -a "$LOG"
        sudo systemctl start ssh.service
        touch ~/.config/.sift
        info-message "SITF installation finished."
    fi
}

function update-sift() {
    START_FRESHCLAM=1
    info-message "Start SITF upgrade."
    # shellcheck disable=SC2024
    if sudo service clamav-freshclam status | grep "Active: active" >> "$LOG" 2>&1; then
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

# Arkime
function install-arkime() {
    install-arkime-common
    install-nfa
}

function install-nfa() {
    if [[ ! -e ~/.config/.nfa ]]; then
        info-message "Start installation of nfa for Arkime."

        cd || exit
        git clone https://github.com/reuteras/nfa.git > /dev/null 2>&1
        cd nfa || exit
        make apt-install >> "$LOG" 2>&1
        make install >> "$LOG" 2>&1
        cp "${HOME}/remnux-tools/files/nfa-config.ini" "${HOME}/nfa/config.ini"

        info-message "Start nfa for Arkime."
        screen -dm -S nfa bash -c "make run"
        info-message "Add automatic start of nfa for Arkime to current user crontab."
        echo "@reboot cd $HOME/nfa && screen -dm -S nfa bash -c 'make run'" | crontab -

        [ ! -d "${HOME}/.config" ] && mkdir "${HOME}/.config"
        touch "${HOME}/.config/.nfa"
        info-message "Installation of nfa for Arkime finished."
        cd || exit
    fi
}

function install-arkime-common() {
    if [[ ! -e ~/.config/.arkime ]]; then
        info-message "Start installation of Arkime."
        if [[ "$(uname -m)" == "aarch64" ]]; then
            ARCH="arm64"
        else
            ARCH="amd64"
        fi

        if test -f /etc/os-release && grep "Debian" /etc/os-release > /dev/null; then
            OS="Debian"
        else
            OS="Ubuntu"
        fi

        if [[ "${OS}" == "Debian" ]]; then
            URL="https://github.com/arkime/arkime/releases/download/v${ARKIME_VERSION}/arkime_${ARKIME_VERSION}-1.debian12_${ARCH}.deb"
            DEB="arkime_${ARKIME_VERSION}-1.debian12_${ARCH}.deb"
            USERGROUP="user:user"
        else
            URL="https://github.com/arkime/arkime/releases/download/v${ARKIME_VERSION}/arkime_${ARKIME_VERSION}-1.ubuntu2204_${ARCH}.deb"
            DEB="arkime_${ARKIME_VERSION}-1.ubuntu2204_${ARCH}.deb"
            USERGROUP="malware:malware"
        fi
        {
            DEBIAN_FRONTEND=noninteractive sudo apt -y -qq install \
                default-jre
            wget --quiet "$URL"
            sudo dpkg --install "$DEB" || true
            sudo apt -y --fix-broken install
            rm -f "$DEB"
        } >> "$LOG" 2>&1

        sudo touch /opt/arkime/etc/config-local.ini
        sudo curl -s -o /opt/arkime/etc/cacert.pem https://curl.se/ca/cacert.pem
        sudo chown "$USERGROUP" /opt/arkime/etc/config-local.ini
        {
            echo '[default]'
            echo "caTrustFile=/opt/arkime/etc/cacert.pem"
            echo "cronQueries=true"
            echo "magicMode=both"
            echo "maxReqBody=0"
            echo "parseCookieValue=true"
            echo "parseDNSRecordAll=true"
            echo "parseHTTPHeaderRequestAll=true"
            echo "parseHTTPHeaderResponseAll=true"
            echo "parseHTTPHeaderValueMaxLen=1048576"
            echo "parseQSValue=true"
            echo "parseSMB=true"
            echo "parseSMTP=true"
            echo "parseSMTPHeaderAll=true"
            echo "queryAllIndices=true"
            echo "readTruncatedPackets=true"
            echo "spiDataMaxIndices=1048576"
            echo "supportSha256=true"
            echo "suricataAlertFile=/var/log/suricata/eve.json"
            echo "suricataExpireMinutes=10512000"
            echo "turnOffGraphDays=36500"
            echo "wiseHost=127.0.0.1"
            echo ""
            echo "[headers-http-request]"
            echo "referer=type:string;count:true;unique:true"
            echo ""
            echo "[headers-http-response]"
            echo "location=type:string"
            echo "server=type:string"
        } > /opt/arkime/etc/config-local.ini
        info-message "Change defaults for Configure script for Arkime"
        ARKIME_INTERFACE=$(ip addr | grep ens | grep "state UP" | cut -f2 -d: | sed -e "s/ //g")
        ARKIME_PASSWORD="password"
        ARKIME_ELASTICSEARCH="http://localhost:9200"
        export ARKIME_INTERFACE ARKIME_PASSWORD ARKIME_ELASTICSEARCH
        sudo sed -i -e "s/ARKIME_INET=not-set/ARKIME_INET=yes/" /opt/arkime/bin/Configure
        sudo sed -i -e "s/ARKIME_INSTALLELASTICSEARCH=not-set/ARKIME_INSTALLELASTICSEARCH=yes/" /opt/arkime/bin/Configure
        sudo sed -i -e "s/read -r ARKIME_ELASTICSEARCH_/echo | read -r ARKIME_ELASTICSEARCH_/" /opt/arkime/bin/Configure
        {
            info-message "Run Configure for Arkime"
            sudo -E /opt/arkime/bin/Configure
            info-message "Run Configure for Arkime --wise"
            sudo -E /opt/arkime/bin/Configure --wise
            info-message "Run Configure for Arkime --cont3xt"
            sudo -E /opt/arkime/bin/Configure --cont3xt
        } >> "$LOG" 2>&1
        sudo sed -i -e "s_#includes=_includes=/opt/arkime/etc/config-local.ini_" /opt/arkime/etc/config.ini
        sudo sed -i -e "s/# plugins=tagger.so; netflow.so/plugins=suricata.so; wise.so; tagger.so/" /opt/arkime/etc/config.ini
        sudo sed -i -e "s/# viewerPlugins=wise.js/viewerPlugins=wise.js/" /opt/arkime/etc/config.ini
        sudo sed -i -e "s/#uploadCommand/uploadCommand/" /opt/arkime/etc/config.ini
        sudo sed -i -e "s/#geoLite/geoLite/" /opt/arkime/etc/config.ini

        info-message "Start elasticsearch.service"
        {
            sudo systemctl start elasticsearch.service
            sudo systemctl enable elasticsearch.service
        } >> "$LOG" 2>&1
        sleep 30
        info-message "Init elasticsearch.service"
        echo "INIT" | /opt/arkime/db/db.pl http://127.0.0.1:9200 init
        info-message "Add users admin and api to arkime"
        /opt/arkime/bin/arkime_add_user.sh admin "Admin User" password --admin --email >> "$LOG" 2>&1
        /opt/arkime/bin/arkime_add_user.sh api "API account" password --email >> "$LOG" 2>&1

        info-message "Create bin directory and add start-arkime.sh script."
        [ ! -d "${HOME}/bin" ] && mkdir -p "${HOME}/bin"
        cp "${HOME}/remnux-tools/files/start-arkime.sh" "${HOME}/bin/start-arkime.sh"
        cp "${HOME}/remnux-tools/files/download-test-pcaps.sh" "${HOME}/bin/download-test-pcaps.sh"
        cp "${HOME}/remnux-tools/files/add-pcaps.sh" "${HOME}/bin/add-pcaps.sh"
        sudo cp "${HOME}/remnux-tools/files/wise.ini" "/opt/arkime/etc/wise.ini"
        # shellcheck disable=SC2024
        sudo systemctl restart arkimewise.service >> "$LOG" 2>&1
        sudo cp "${HOME}/remnux-tools/files/valueactions-nfa.ini" "/opt/arkime/etc/valueactions-nfa.ini"
        sudo cp "${HOME}/remnux-tools/files/valueactions-otx.ini" "/opt/arkime/etc/valueactions-otx.ini"
        sudo cp "${HOME}/remnux-tools/files/valueactions-virustotal.ini" "/opt/arkime/etc/valueactions-virustotal.ini"

        info-message "Enable and start arkimeviewer."
        {
            sudo systemctl enable arkimeviewer.service
            sudo systemctl start arkimeviewer.service
        } >> "$LOG" 2>&1

        [ ! -d "${HOME}/.config" ] && mkdir "${HOME}/.config"
        touch "${HOME}/.config/.arkime"
        info-message "Arkime installation finished."
        cd || exit
    fi
}

function update-Arkime() {
    info-message "Start Arkime upgrade."
    info-message "   ## NOTHING TODO ##"
    info-message "Arkime upgrade finished."
}

# Suricata
function install-suricata() {
    if [[ ! -e ~/.config/.suricata ]]; then
        info-message "Start installation of Suricata."
        {
            sudo add-apt-repository -y -u ppa:oisf/suricata-stable
            DEBIAN_FRONTEND=noninteractive sudo apt -y -qq install suricata
            sudo suricata-update
            sudo suricata-update update-sources
            sudo suricata-update enable-source oisf/trafficid
            sudo suricata-update enable-source sslbl/ja3-fingerprints
            sudo suricata-update enable-source sslbl/ssl-fp-blacklist
            sudo suricata-update enable-source et/open
            sudo suricata-update enable-source stamus/lateral
            sudo suricata-update enable-source malsilo/win-malware
            sudo suricata-update enable-source tgreen/hunting
            sudo suricata-update enable-source etnetera/aggressive
            sudo suricata-update enable-source pawpatrules
            sudo cp "${HOME}/remnux-tools/files/disable.conf" "/etc/suricata/disable.conf"
            sudo cp "${HOME}/remnux-tools/files/suricata.yaml" "/etc/suricata/suricata.yaml"
            sudo cp "${HOME}/remnux-tools/files/update.yaml" "/etc/suricata/update.yaml"
            sudo suricata-update
        } >> "$LOG" 2>&1
        info-message "Suricata installation finished."
    fi
}

function install-vmbin() {
    info-message "Installing vmbin"
    if [[ ! -d ~/src/vmbin ]]; then
        cd ~/src || exit
        git clone https://github.com/reuteras/vmbin.git >> "$LOG" 2>&1
        cd || exit
    fi
    info-message "Done installing vmbin"
}
