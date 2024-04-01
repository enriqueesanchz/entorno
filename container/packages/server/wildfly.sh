#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="wildfly"
version="23.0.2.Final"
GV="4.2.8.Final"
url="https://github.com/wildfly/galleon/releases/download/${GV}/galleon-${GV}.zip"

install() {
    wget ${url} -O /tmp/galleon-${GV}.zip
    unzip /tmp/galleon-${GV}.zip -d /opt
    ln -s /opt/galleon-${GV} /opt/galleon
    /opt/galleon/bin/galleon.sh install ${package}#${version} --dir=/opt/${package}
    groupadd -r ${package}
    useradd -r -g ${package} -d /opt/${package} -s /sbin/nologin ${package}
    mkdir -p /etc/${package}
    cp /opt/${package}/docs/contrib/scripts/systemd/${package}.conf /etc/${package}
    cp /opt/${package}/docs/contrib/scripts/systemd/launch.sh /opt/${package}/bin/
    chmod +x /opt/${package}/bin/*.sh
    cp /opt/${package}/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/
}

clean() {
    rm /tmp/galleon-${GV}.zip
}

remove() {
    rm -rf /opt/galleon-${GV}
    rm /opt/galleon
    rm -rf /opt/${package}
    groupdel ${package}
    userdel -r ${package}
    rm -rf /etc/${package}
}

trap clean EXIT

main() {
    install
    printf "[binary] Succesfully installed ${package}\n"
}

main
