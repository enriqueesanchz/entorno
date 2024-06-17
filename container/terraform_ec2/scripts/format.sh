#!/bin/bash

DEVICE="/dev/xvdh"

mkdir -p volumes
fs_type=$(blkid -o value -s TYPE ${DEVICE})
if [ -n "${fs_type}" ]; then
    echo "El dispositivo ${DEVICE} está formateado con ${fs_type}."
    mount ${DEVICE} volumes
else
    echo "El dispositivo ${DEVICE} no está formateado."
    mkfs -t xfs ${DEVICE}
    mount ${DEVICE} volumes
fi
