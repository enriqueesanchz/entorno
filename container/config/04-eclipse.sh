#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="eclipse"

# Config
configure() {
    # add to PATH
    ln -s /opt/eclipse/eclipse /usr/bin/eclipse
}

clean() { 
    :
}

remove() {
    rm /usr/bin/eclipse
}

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

