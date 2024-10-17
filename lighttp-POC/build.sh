#!/bin/sh

PKGS="lighttpd"
SCRIPT_PATH=$(echo $(dirname $(realpath "$0")))
OUTPUT_DIR=$(realpath ${1%/})

if [ "$(whoami)" != "root" ]; then
    echo "This script needs root permissions."
    exit 1
fi

cp /etc/localtime ${OUTPUT_DIR}/etc/localtime
cp /etc/resolv.conf ${OUTPUT_DIR}/etc/resolv.conf


pkg -c ${OUTPUT_DIR} install ${PKGS}
mkdir ${OUTPUT_DIR}/webpage
cp ${SCRIPT_PATH}/conf/usr/local/etc/lighttpd/lighttpd.conf ${OUTPUT_DIR}/usr/local/etc/lighttpd/lighttpd.conf
cp ${SCRIPT_PATH}/conf/webpage/index.html ${OUTPUT_DIR}/webpage/index.html
printf "\tpath = '${OUTPUT_DIR}';\n}" >> ${SCRIPT_PATH}/host-conf/httpBoat.conf
