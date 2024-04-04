#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="tigervnc-standalone-server"

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
    printf "[apt-get] Succesfully installed ${package}\n"
}

main
