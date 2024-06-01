#!/bin/bash

# Strict mode
set -euo pipefail

# /code
if [ -z "$(ls -A /code 2>/dev/null)" ]; then
    printf "/code vacio, clonando quickstart\n" 1>&2
    git clone https://github.com/wildfly/quickstart.git /code/quickstart
else
    printf "usando volumes/code\n" 1>&2
fi

# mysql permission
chown -R mysql:mysql /var/lib/mysql

# vnc session
mkdir -p /home/sigma/.vnc
echo ${tigervncpasswd} | vncpasswd -f > /home/sigma/.vnc/passwd
chmod 600 /home/sigma/.vnc/passwd

chown -R sigma:sigma /home/sigma

cd /home/sigma
sudo -u sigma vncserver -localhost no
