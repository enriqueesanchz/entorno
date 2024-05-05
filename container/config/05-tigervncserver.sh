#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="tightvncserver"

# Config
configure() {
    mkdir /home/sigma/.vnc
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

