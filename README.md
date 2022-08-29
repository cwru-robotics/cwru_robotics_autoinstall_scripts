# `cwru_robotics_autoinstall_scripts` Package

This repository provides autoinstall files that will allow nearly automated installations for robots and workstations used by CWRU Robotics researchers.

## Usage

As of Ubuntu 20.04, [Ubuntu Server](https://ubuntu.com/download/server) can use an auto-installation mechanism that includes being able to retrieve the installation configuration from the internet.  Ubuntu Server can be converted into Ubuntu Desktop by installing the `ubuntu-desktop` package.  More information about how to create and use the autoinstall capabilities of Ubuntu Server can be found on the [Ubuntu website](https://ubuntu.com/server/docs/install/autoinstall).

This repository will have directories for various types of installations.  Find the URL to the **RAW** `user-config` file.  Truncate the filename from that URL and add it to the kernel commandline of the image being installed.

> `autoinstall ds=nocloud-net;s=https://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/main/basic/` 

Each directory must include both a `user-config` and a `meta-data` file.  The former contains most of the installation information, while the latter is generally expected to be empty.

## `user-data`

This is the file that contains the most of the auto-installation information at this time.  It is a YAML file.  Use the [Ubuntu reference](https://ubuntu.com/server/docs/install/autoinstall-reference) to understand the structure of the file. 

The most basic file contains "identity" the hostname of the computer, the real name of the user, username, and the password "crypted".  The basic command to get a crypted password is:

> ```printf 'ubuntu' | openssl passwd -6 -stdin```

> `$6$FhcddHFVZ7ABA4Gi$XOmu9O8SDaBexz6Zw0FCjeZJbwPP.OTK7TTZp8G/BydFXvlpHQxuuMHPzZ3IGgt3u5n73a1EkysSCendbXCDG1`

The `printf` element ensures that no extra bytes are included in the password being crypted.  This command is randomly salted, so the it highly unlikely that this will be the string returnw when run again.

It is possible to add a specific salt so that the output can be verified to be returning what it should.  To reproduce the crypted password shown here add the following as the salt: `FhcddHFVZ7ABA4Gi`.  (The salt is between the `$6$` and the next `$`.)

> ```printf 'ubuntu' | openssl passwd -6 -salt 'FhcddHFVZ7ABA4Gi' -stdin```


The output should now be the same as above.  It is best practice to allow the salt to be generated randomly (or at least not use the same salt repeatedly).

## `meta-data`

This file is emtpy at this time.  It must be present in the system, however, in order for the automated installation to work.
