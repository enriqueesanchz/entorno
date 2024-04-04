#!/bin/bash

# Strict mode
set -euo pipefail

# Para acceder a la configuracion desde el host:
# 1. Persistir una config default en /default
# 2. Añadir el directorio a la lista de directorios
# 3. Montar un volumen en dicho directorio (compose)

dirs=("/opt/wildfly/standalone"
    "/etc/apache2"
    "/etc/sigma"
    "/home/sigma"
    "/var/lib/mysql"
    "/etc/openfortivpn/")

for dir in "${dirs[@]}"; do
    if [ -z "$(ls -A ${dir})" ]; then
        printf "${dir} vacio, usando default\n" 1>&2
        cp -rT /default${dir} ${dir} # -T: no crear directorio en destino
    else
        printf "usando volumes${dir}\n" 1>&2
    fi
done

# mysql permission
chown -R mysql:mysql /var/lib/mysql

vncserver -localhost no -fg

