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
    tar xzf /static.tar.gz -C / ./etc/sigma
}

clean() { 
    mkdir -p /default/etc/sigma
    cp -r /etc/sigma /default/etc/
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

