#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="tigervncserver"

# Config
configure() {
    mkdir -p /home/sigma/.vnc
    echo ${tigervncpasswd} | vncpasswd -f > /home/sigma/.vnc/passwd
    chmod 600 /home/sigma/.vnc/passwd
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

