This is a boat jail for firefox.
It assumes you use X11 and the display is at `:0`. Changing it is very easy, just change up the parameters in jail configuration.

Installation instructions:

ALL INSTRUCTIONS ARE DONE WITH ROOT ACCOUNT!

extract a base.txz filesystem to a directory. (This can also be a ZFS clone of a snapshot of an extracted base.txz dataset. It only expects it to be a rootfs that it can modify.)
`tar -xf /path/to/base.txz -C /path/to/jail --unlink`

Run the script
`sh /path/to/build.sh /path/to/extracted/base/filesystem`

The generated jail configuration is at host-conf, You may want to install this via merging with /etc/jail.conf or copying to /etc/jail.conf.d/
This jail also provides a devfs configuration WHICH IS REQUIRED! It is at host-conf/devfs_rules You can install it with this command:
`cat host-conf/devfs_rules >> /etc/devfs.rules`

At this point, it should be done!
`jail -c jailfox`
