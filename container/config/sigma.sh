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
    tar zxf /tmp/default/etc/sigma/sigmatree.tgz -C /
}

clean() { :;}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

