#!/bin/bash

# Strict mode
set -euo pipefail

# Para acceder a la configuracion desde el host:
# 1. Persistir una config default en /default
# 2. Añadir el directorio a la lista de directorios
# 3. Montar un volumen en dicho directorio (compose)

dirs=("/opt/wildfly/standalone"
    "/etc/apache2"
    "/home/sigma"
    "/var/lib/mysql"
    "/etc/openfortivpn/"
    "/root/.vnc")

for dir in "${dirs[@]}"; do
    if [ -z "$(ls -A ${dir})" ]; then
        printf "${dir} vacio, usando default\n" 1>&2
        cp -rT /default${dir} ${dir} # -T: no crear directorio en destino
    else
        printf "usando volumes${dir}\n" 1>&2
    fi
done

# /code
if [ -z "$(ls -A /code)" ]; then
    printf "/code vacio, clonando quickstart\n" 1>&2
    git clone https://github.com/wildfly/quickstart.git /code/quickstart
else
    printf "usando volumes/code\n" 1>&2
fi

# mysql permission
chown -R mysql:mysql /var/lib/mysql

vncserver -localhost no -fg

