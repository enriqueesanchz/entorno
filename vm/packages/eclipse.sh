#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="eclipse"
url='https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2023-12/R/eclipse-jee-2023-12-R-linux-gtk-x86_64.tar.gz&r=1'

install() {
    wget ${url} -O /tmp/${package}.tar.gz
    tar -xzf /tmp/${package}.tar.gz -C /opt 2> /dev/null
    chmod +x /opt/eclipse/eclipse

    # eclipse in PATH
    ln -s /opt/eclipse/eclipse /usr/bin/eclipse
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
