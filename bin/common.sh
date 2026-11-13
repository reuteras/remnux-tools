#!/bin/bash

ARKIME_VERSION="6.9.2"

# REMnux installer (https://docs.remnux.org/install-distro/install-from-scratch).
# Tracked by .github/workflows/remnux-installer.yml - review the diff of
# files/remnux-installer in the generated PR before merging.
REMNUX_INSTALLER_URL="https://REMnux.org/remnux"
REMNUX_INSTALLER_SHA256="c1e2dbc7191c4c3382deea2c5ecc40d729c271b7d6b8897caa5cbeb7e3e7d203"

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

function update-ubuntu() {
    info-message "Updating Ubuntu."
    info-message "Running apt update."
    # shellcheck disable=SC2024
    sudo apt update >> "$LOG" 2>&1
    info-message "Running apt dist-upgrade."
    # shellcheck disable=SC2024
    while ! sudo DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade >> "$LOG" 2>&1; do
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
        libncurses-dev \
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
        if ! dpkg --status chromium-browser > /dev/null 2>&1; then
            info-message "Installing chromium."
            # shellcheck disable=SC2024
            DEBIAN_FRONTEND=noninteractive sudo apt -y -qq install chromium-browser >> "$LOG" 2>&1
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
            geoip-database \
            geoipupdate \
            mmdb-bin \
            python3-geoip \
            python3-geoip2 >> "$LOG" 2>&1
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

# Main install and update functions
# REMnux
function install-remnux() {
    if [[ ! -e ~/.config/.remnux ]]; then
        info-message "Start installation of Remnux."
        local tmp_dir
        tmp_dir=$(mktemp -d)
        wget --quiet -O "$tmp_dir/remnux" "$REMNUX_INSTALLER_URL" ||
            error-exit-message "Couldn't download $REMNUX_INSTALLER_URL."
        if ! echo "$REMNUX_INSTALLER_SHA256  $tmp_dir/remnux" | sha256sum --check --status; then
            rm -rf "$tmp_dir"
            error-exit-message "SHA256 mismatch for REMnux installer. Review and update REMNUX_INSTALLER_SHA256."
        fi
        chmod +x "$tmp_dir/remnux"
        sudo mv "$tmp_dir/remnux" /usr/local/bin/remnux
        rm -rf "$tmp_dir"
        sudo apt install -y gnupg
        sudo systemctl stop ssh.service
        sudo /usr/local/bin/remnux install --user="$USER"
        sudo systemctl start ssh.service
        touch ~/.config/.remnux
        info-message "Remnux installation finished."
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
            # shellcheck source=/dev/null
            source /etc/os-release
            URL="https://github.com/arkime/arkime/releases/download/v${ARKIME_VERSION}/arkime_${ARKIME_VERSION}-1.debian${VERSION_ID}_${ARCH}.deb"
            DEB="arkime_${ARKIME_VERSION}-1.debian${VERSION_ID}_${ARCH}.deb"
            USERGROUP="user:user"
        else
            URL="https://github.com/arkime/arkime/releases/download/v${ARKIME_VERSION}/arkime_${ARKIME_VERSION}-1.ubuntu2204_${ARCH}.deb"
            DEB="arkime_${ARKIME_VERSION}-1.ubuntu2204_${ARCH}.deb"
            USERGROUP="malware:malware"
        fi
        {
            DEBIAN_FRONTEND=noninteractive sudo apt -y -qq install \
                default-jre \
                screen
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
        sudo sed -i -e "s/ARKIME_INET=not-set/ARKIME_INET=no/" /opt/arkime/bin/Configure
        sudo sed -i -e "s/ARKIME_INSTALLELASTICSEARCH=not-set/ARKIME_INSTALLELASTICSEARCH=yes/" /opt/arkime/bin/Configure
        sudo sed -i -e "s/read -r ARKIME_ELASTICSEARCH_/echo | read -r ARKIME_ELASTICSEARCH_/" /opt/arkime/bin/Configure
        {
            info-message "Run Configure for Arkime"
            echo "$ARKIME_INTERFACE" | sudo -E /opt/arkime/bin/Configure
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
        sudo cp "${HOME}/remnux-tools/files/valueactions-spur.ini" "/opt/arkime/etc/valueactions-spur.ini"
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

function update-arkime() {
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
        [[ -d ~/src ]] || mkdir ~/src
        cd ~/src || exit
        git clone https://github.com/reuteras/vmbin.git >> "$LOG" 2>&1
        cd || exit
    fi
    info-message "Done installing vmbin"
}
