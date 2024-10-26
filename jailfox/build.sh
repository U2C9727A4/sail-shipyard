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
alias chexec="chroot ${OUTPUT_DIR}/"

if [ "$(whoami)" != "root" ]; then
    echo "This script needs root permissions."
    exit
fi

echo "The host requires the package `xhost`. Installing it."
pkg install xhost

pkg -c ${OUTPUT_DIR} install ${PKGS}
mkdir -p ${OUTPUT_DIR}/tmp/.X11-unix
chmod 755 ${OUTPUT_DIR}/tmp/.X11-unix

# User for running firefox
chexec pw useradd firefox -m


# Populate jail configuration
printf "\tpath = '${OUTPUT_DIR}';\n\texec.prestart = 'export DISPLAY=\":0\" ; mount_nullfs /tmp/.X11-unix ${OUTPUT_DIR}/tmp/.X11-unix ; xhost + || true';\n}" >> ${SCRIPT_PATH}/host-conf/jailfox.conf

echo "Jail build has been completed."
echo "You can now copy over host-conf/jailfox.conf to your jail configurations, and merge host-conf/devfs_rules with /etc/devfs.rules"