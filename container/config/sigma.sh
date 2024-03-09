#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="sigma"

# Config
file="sigmatree.tgz"

# Config
configure() {
    tar zxf /tmp/static/etc/sigma/sigmatree.tgz -C /
}

clean() { 
    rm -rf /tmp/static/etc/sigma
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

