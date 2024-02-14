#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="apache2"

install() {
    apt-get -y install ${package}
}

clean() {
    apt-get autoremove && apt-get clean
}

remove() {
    apt-get -y remove ${package}
}

trap clean EXIT

main() {
    install
    printf "[apt-get] Succesfully installed ${package}"
}

main
