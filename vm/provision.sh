#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Perl variables
#LC_ALL="en_US.UTF-8"
#dpkg-reconfigure locales

# Update
apt-get -y update && \
echo "wireshark-common wireshark-common/install-setuid boolean true" | \
debconf-set-selections && \
apt-get install -y --no-install-recommends \
    wget \
    git \
    unzip \
    bzip2 \
    default-jre \
    maven \
    tigervnc-standalone-server \
    tigervnc-common \
    openfortivpn \
    firefox-esr \
    xfce4 \
    xfce4-terminal \
    gvfs \
    dbus-x11 \
    mariadb-server \
    tshark \
    sudo && \
apt-get -y -o Dpkg::Options::="--force-confdef" \
-o Dpkg::Options::="--force-confold" install apache2 && \
apt-get autoremove && apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

cd /packages
chmod +x ./eclipse.sh && ./eclipse.sh && \
chmod +x ./wildfly.sh && ./wildfly.sh

adduser sigma sudo && adduser sigma wireshark

cd /config
export db=sigma
export dbuser=sigma
export dbpass=sigmadb
export wild_user=admin
export wild_password=admin
export USER="enrique"
export PASSWORD="123456"

for file in *.sh; do chmod +x ${file} && ./${file}; done

