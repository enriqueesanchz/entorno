#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="tightvncserver"

# Config
configure() {
    mkdir ~/.vnc
    echo ${PASSWORD} | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
}

clean() { 
    :
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

