Installation instructions:

ALL INSTRUCTIONS ARE DONE WITH ROOT ACCOUNT!

extract a base.txz filesystem to a directory.
`tar -xf /path/to/base.txz -C /path/to/jail --unlink`

Run the script
`sh /path/to/build.sh /path/to/extracted/base/filesystem`

The generated jail configuration is at host-conf, You may want to install this via merging with /etc/jail.conf or copying to /etc/jail.conf.d/

start the jail
`jail -c servehttp`

At this point, it should be done!
