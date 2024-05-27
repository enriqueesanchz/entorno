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
    unzip -q /tmp/galleon-${GV}.zip -d /opt
    ln -s /opt/galleon-${GV} /opt/galleon
    /opt/galleon/bin/galleon.sh install ${package}#${version} --dir=/opt/${package}
}

clean() {
    rm /tmp/galleon-${GV}.zip
}

remove() {
    rm -rf /opt/galleon-${GV}
    rm /opt/galleon
    rm -rf /opt/${package}
}

trap clean EXIT

main() {
    install
    printf "[binary] Succesfully installed ${package}\n"
}

main
