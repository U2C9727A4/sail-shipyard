#   NOTE
#       Devfs ruleset number is generated with:
#       `echo "<jail-name>" | md5sum | sed 's/[^0-9]//g' | fold -w 4 | head -n 1`. 
#                   |
#                   > This is "jailfox" in this case.   
#
#       This is so that the devfs number does not conflict with other rules found in it.
# ruleset number: 8185


PKGS="firefox liberation-fonts-ttf mesa-dri egl"
SCRIPT_PATH=$(echo $(dirname $(realpath "$0")))
OUTPUT_DIR=$(realpath ${1%/})
HOST_PKGS="xhost"
FILES="devfs_rules jailfox.conf"

# function to check if the specified field exists in file.
# $1 = field
# $2 = file
# NOTE the sed part removes stuff that is commented out.
chkfield() {
    cat $2 | sed -E 's/#.*//g' | grep "$1"
}
# function to check if file exists in SCRIPT_PATH.
chkfile() {
    find ${SCRIPT_PATH} -name "$1"
}
# alias to execute a given command in OUTPUT_DIR
alias chexec="chroot ${OUTPUT_DIR}/"

# Root permission check
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

echo "The host requires the package(s) \"${HOST_PKGS}\". Installing it."

# Package installation check, retry 3 times before exiting.
PKG_RETRIES=0
while :
do
    pkg install ${HOST_PKGS}
    # Package installation check
    if [ $? != 0 ]; then
        echo "Host package installation failed."
        echo "Trying again..."
    else
        break
    fi
    if [ $PKG_RETRIES -gt 3 ]; then 
        echo "Maximum retry reached. Cannot continue."
        exit 1
    fi

    PKG_RETRIES=$(expr ${PKG_RETRIES} + 1)
done

cp /etc/localtime ${OUTPUT_DIR}/etc/localtime
cp /etc/resolv.conf ${OUTPUT_DIR}/etc/resolv.conf

# Package installation check, retry 3 times before exiting.
PKG_RETRIES=0
while :
do
    pkg -c ${OUTPUT_DIR} install ${PKGS}
    # Package installation check
    if [ $? != 0 ]; then
        echo "Package installation failed."
        echo "Trying again..."
    else
        break
    fi
    if [ $PKG_RETRIES -gt 3 ]; then 
        echo "Maximum retry reached. Cannot continue."
        exit 1
    fi

    PKG_RETRIES=$(expr ${PKG_RETRIES} + 1)
done


mkdir -p ${OUTPUT_DIR}/tmp/.X11-unix
chmod 755 ${OUTPUT_DIR}/tmp/.X11-unix

# User for running firefox
chexec pw useradd firefox -m
if [ $? != 0 ] && ! chexec pw usershow firefox >/dev/null 2>&1; then 
    echo "Firefox user creation failed. Cannot continue."
    exit 1
fi


# Populate jail configuration
if chkfield "path" "${SCRIPT_PATH}/host-conf/jailfox.conf" >/dev/null 2>&1; then
    echo "Path field already exists in jailfox.conf. Please re-clone this boat."
    exit 1
fi

if chkfield "exec.prestart" "${SCRIPT_PATH}/host-conf/jailfox.conf" >/dev/null 2>&1; then
    echo "exec.prestart already exists in jailfox.conf. Please re-clone this boat."
    exit 1
fi
BRACES=$(chkfield "}" "${SCRIPT_PATH}/host-conf/jailfox.conf" | sed 's/{[^{}]*}//g') # the sed here is for clearing out paired braces.
if [ -z $BRACES ]; then
    echo "Closing brace already exists in jailfox.conf. Please re-clone this boat."
    exit 1
fi

printf "\tpath = '${OUTPUT_DIR}';\n\texec.prestart = 'export DISPLAY=\":0\" ; mount_nullfs /tmp/.X11-unix ${OUTPUT_DIR}/tmp/.X11-unix ; xhost + || true';\n}" >> ${SCRIPT_PATH}/host-conf/jailfox.conf

echo "Jail build has been completed."
echo "You can now copy over host-conf/jailfox.conf to your jail configurations, and merge host-conf/devfs_rules with /etc/devfs.rules"
