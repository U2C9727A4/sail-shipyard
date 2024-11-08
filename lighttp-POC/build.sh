#!/bin/sh

PKGS="lighttpd"
SCRIPT_PATH=$(echo $(dirname $(realpath "$0")))
OUTPUT_DIR=$(realpath ${1%/})
FILES="index.html lighttpd.conf httpBoat.conf"

# alias to check if the specified field exists in file.
# $1 = field
# $2 = file
alias chkfield="cat $2 | grep $1"

# alias to check if file exists in SCRIPT_PATH.
alias chkfile="find ${SCRIPT_PATH} -name '${1}'"

# root permission check
if [ "$(whoami)" != "root" ]; then
    echo "This script needs root permissions."
    exit 1
fi

# Output directory write permission check
if [ ! -w "${OUTPUT_DIR}" ]; then
    echo "No write permission to output directory. Cannot continue."
    exit 1
fi

# File existence check
FILE_AMOUNT=$(expr $(echo ${FILES} | wc -w) + 1) # Increment by one because non-zero indexing.
FILES_CHECKED=1 # Start with 1 because non-zero indexing.
set -- $FILES

while [ "$FILES_CHECKED" -le "$FILE_AMOUNT" ]; do
    FILE_TO_CHECK=$(eval echo \${$FILES_CHECKED})
    
    if [ -z "$(chkfile "$FILE_TO_CHECK")" ]; then
        echo "A file does not exist. Cannot continue."
        exit 1
    fi

    FILES_CHECKED=$((FILES_CHECKED + 1))
done

cp /etc/localtime ${OUTPUT_DIR}/etc/localtime
cp /etc/resolv.conf ${OUTPUT_DIR}/etc/resolv.conf

# Package installation check, retry 3 times before exiting.
PKG_RETRIES=0
while true do;
    pkg -c ${OUTPUT_DIR} install ${PKGS}
    # Package installation check
    if [ $? != 0 ]; then
        echo "Package installation failed."
        echo "Trying again..."
    fi
    if [ $PKG_RETRIES > 3 ]; then 
        echo "Maximum retry reached. Cannot continue."
        exit 1
    fi

    PKG_RETRIES=$(expr ${PKG_RETRIES} + 1)
done

mkdir ${OUTPUT_DIR}/webpage
cp ${SCRIPT_PATH}/conf/usr/local/etc/lighttpd/lighttpd.conf ${OUTPUT_DIR}/usr/local/etc/lighttpd/lighttpd.conf
cp ${SCRIPT_PATH}/conf/webpage/index.html ${OUTPUT_DIR}/webpage/index.html


printf "\tpath = '${OUTPUT_DIR}';\n}" >> ${SCRIPT_PATH}/host-conf/httpBoat.conf
