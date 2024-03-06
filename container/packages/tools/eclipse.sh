#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="eclipse"
url='https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2023-12/R/eclipse-jee-2023-12-R-linux-gtk-x86_64.tar.gz&r=1'

install() {
    wget ${url} -O /tmp/${package}.tar.gz
    tar -xzf /tmp/${package}.tar.gz -C /opt
    chmod +x /opt/eclipse/eclipse
}

clean() {
    rm /tmp/${package}.tar.gz
}

remove() {
    rm -rf /opt/eclipse
}

trap clean EXIT

main() {
    install
    printf "[binary] Succesfully installed ${package}\n"
}

main
