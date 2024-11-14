# Shipyard
This repository contains the "boats" for sail.

  ## Requirements
  Needs `pkg` to be available and working on the host.

  ## Licenses
  The repo itself is BSD 2-claude license, but some programs in the boats can use diffirent licenses, just so you know.

# FOR DEVELOPERS

  ## Expected boat layout
  captain expects the following directories on the root of the boat: `host-conf`
  and expects `build.sh` as the script to build the boat, or atleast as an entry point.
  config files for programs inside the jail can be wherever, but treating conf as a overlay over the actual jail filesystem is a good practice.

  ## Hints
  in `host-conf` a special file `captain.hints` MUST EXIST!
  this hints file tells captain where the jail configuration is, and its respective devfs rules.
  It also tells captain which packages on the host the boat requires.

  ### Fields
    `jailconf` Path to the jail configuration file. (Relative to top directory of the boat.)
    `devfs_rules` Path to the devfs_rules file. (Relative to top directory of the boat.) . Optional.
    `host_pkgs` The packages required by the boat on the host. Optional.
    `boatname` Name of the boat.

  ## Expected built.sh arguements
  captain excepts the first arguement (`./build.sh FirstArguement`) (is `$1` in `sh`) to be a path to the jail filesystem.
  So, if the user wants to install a jail to `/jail/myjail` the script should be able to run with this: `./build.sh /jail/myjail`.
