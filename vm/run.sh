#!/bin/bash

# Perl variables
export LC_ALL="en_US.UTF-8"
dpkg-reconfigure locales

# Update
apt-get update -y

# Install packages

folders=(
    '/vagrant/packages/base'
    '/vagrant/packages/java'
    '/vagrant/packages/server'
    '/vagrant/packages/tools'
    '/vagrant/packages/viewer')

for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        cd "$folder" || continue
        
        for archivo in *.sh; do
            [ -f "$archivo" ] && [ -x "$archivo" ] && "./$archivo"
        done
        
        cd - || exit
    else
        echo "La folder $folder no existe."
    fi
done

# Configure

folders=(
    '/vagrant/config/'
)

for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        cd "$folder" || continue
        
        for archivo in *.sh; do
            [ -f "$archivo" ] && [ -x "$archivo" ] && "./$archivo"
        done
        
        cd - || exit
    else
        echo "La folder $folder no existe."
    fi
done

