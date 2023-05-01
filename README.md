# `cwru_robotics_autoinstall_scripts` Package

This repository provides autoinstall files that automates Ubuntu/ROS installations for robots and workstations for CWRU Robotics researchers.

This package is still under development.  These scripts are not well verified at this time.

## Usage

As of Ubuntu 20.04, [Ubuntu Server](https://ubuntu.com/download/server) can use an auto-installation mechanism that includes being able to retrieve the installation configuration from the internet.  Ubuntu Server can be converted into Ubuntu Desktop by installing the `ubuntu-desktop` package.  More information about how to create and use the autoinstall capabilities of Ubuntu Server can be found on the [Ubuntu website](https://ubuntu.com/server/docs/install/autoinstall).

This repository will have directories for various types of installations.  The autoinstall requires the URI of the location of the **RAW** `user-data` and `meta-data` files.  The URL is [`raw.githubusercontent.com`](http://raw.githubusercontent.com), not [`github.com`](https://github.com).

During the boot process of the Ubuntu Server Live CD, hold the Shift key down.  A boot menu should appear.  Press F6, and escape.  The kernel command line is available for editing.  Add the following line to the boot configuration text:

> `autoinstall ds=nocloud-net;s=https://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/<linux_name>/<install_type>/` 

If the Grub2 Boot Menu appears, the process is slightly different.  Press the "e" key to edit the "Ubuntu Installation" option.  On the line that begins with "linux", type the text below at the end of the line.  Notice here that there is a backslash (\) before the semicolon between "nocloud-net" and ";".

> `autoinstall ds=nocloud-net\;s=https://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/<linux_name>/<install_type>/` 


Where the `<install_type>` is in the repository that contains at least `user-data` and `meta-data` files.  The former contains the installation information, while the latter is generally expected to be empty.  It is required that `meta-data` be present in the directory even if empty.

Currently, the `hostname` will need to be updated when the system is ready to run.

### Failed Attempt

If the installation shows a menu to select the language for the installation, the autoinstallation has failed.  Before trying again review the logs.  

While the language selection option is still up, press CTRL+ALT+F2.  This switches to a second virtual termina and a command prompt should come up.  Review the error log for the cloud-init autoinstallation with the following command: `less /var/log/cloud-init.log`.  Look through the file for references to the `meta-data` file downloaded from the URL above.  That file is downloaded first.  If it is not there, the problem is with contacting the server holding the files (GitHub).  If it is there, check just after it to verify that the `user-data` file was downloaded successfully.  If they are both downloaded, that indicates the problem is with the `user-data` file.  It would be unusual for `meta-data` to have downloaded successfully and `user-data` to have failed. 

It may be necessary to review the syslog as well: `less /var/log/syslog`.  The kernel command line parameters can be found in this file.  Check to see that the autoinstall line shown above is complete and accurate in this file.

These logs can be placed on another computer using `ssh/scp` if there is a computer configured to accept `ssh` connections.

### Set IP Address Manually

If an IP address has not been configured before the install script attempts to download the configuration file, the download will fail (a known bug in cloud-init exacerbated by the slow allocation of IP addresses by the CWRU network).  It is possible to manually specify the IP address and other information at the kernel command line.  It goes between the `---` and the `autoinstall ds=no...`.

> ```ip=<ip_address>::<gateway>:<netmask>:<hostname>:<network_interface>:none:<dns>[:dns2]```

For the `Atlas#` computers in the Glennan 210 Laboratory which have static IP addresses assigned, retrieve these values from the computer before attempting the installation.  Either boot the computer like normal or boot into the live Ubuntu trial on the USB drive, then go to the Network Settings and write down IP addresses for the computer, gateway, netmask (generally 255.255.255.0), and at least one DNS server.  For the `Atlas#` computers, the network interface is `eno1`.

### Post-Installation

Clean-up is required after this installation method.  After rebooting the computer, the hostname must be changed:

> ```sudo pico /etc/hostname```

Also, remove the `GRUB_CMDLINE_LINUX` entry in the `/etc/default/grub` file that contains the extended kernel command line that specifies the IP Address.  The following command must be run after this file is saved.

> ```sudo update-grub```

Finally, the IP address may need to be reset if the Manual IP Address method was used above.  The following commands should accomplish this:

> ```cloud-init clean --logs```

> ```cloud-init init --local```

> ```cloud-init clean -r```


The final command reboots the computer.  It should be 

## Installations Types

There are three types of installations provided by this repository in this branch which is directed at Ubuntu Server 20.04 Focal Fossa and ROS Noetic Ninjemys.  The naming is based on naming on the ROS installation packages.  All three, however, include the installation of GIT.  All installations all prevent root from being able to remotely login and have `sshd` activated.

The installation names are based on the ROS installation meta-packages defined in [REP 150](https://ros.org/reps/rep-0150.html).

#### `ros-noetic-desktop-full`

This installation is intended for desktop computers with graphics.  Ubuntu Server is a minimal, non GUI installation.  This installation adds the `ubuntu-desktop` meta-package that functionally makes the installation the same as Ubuntu Desktop.  The ROS `ros-noetic-desktop-full` meta-package is installed.

Snap is used to install the VS Code IDE.

### `ros-noetic-perception`

The `ros-noetic-perception` installation meta-package is a "capability variant" ROS installation.  ROS discourages to have graphics dependencies.  It does have image manipulation packages, but no graphical outputs.  It is intended for computers that are installed on robots that are not expected to have GUI and typically run "headless."

### `ros-noetic-robot`

The `ros-noetic-robot` installation meta-package is prohibited from including graphics dependencies.  It is intended for lower-level, embedded computers installed on robots.



## Information on `autoinstall` using `cloud-config`

The `autoinstall` protocol is based on the `cloud-config` system.  There are three possible files that are used by `cloud-config` to automate the installation process.  Ubuntu provides  [documentation](https://ubuntu.com/server/docs/install/autoinstall-reference) for `autoinstall` for Ubuntu Server (beginning with 20.04) is available .  There is also [documentation](https://cloudinit.readthedocs.io/en/latest/) that provides higher level information for `cloud-config`.

### `user-data`

This is the file that contains the most of the auto-installation information at this time.  It is a YAML file.  Use the [Ubuntu reference](https://ubuntu.com/server/docs/install/autoinstall-reference) to understand the structure of the file as it is used for installing Ubuntu (Server 20.04 and newer?). 

The most basic file contains the `identity` tag that sets the hostname of the computer, the real name of the user, username, and the password "crypted".  OpenSSL (`openssl`) can be used to generate a "crypted" password that can be used by the `passwd` file.  This method of providing a password is secure since it is impossible to reconstruct a password from its HASH value.  There are several cryptographic hash algorithms that can be used.  The algorithm is indicated by the number in the second position of the resulting HASH.  View the man page for OpenSSL to learn about the available algorithms and how they are used.  The SHA512 algorithm is indicated by the `-6` element.

> `openssl passwd -6 -salt 'FhcddHFVZ7ABA4Gi' ubuntu`

This command should result in the HASH shown below.

> `$6$FhcddHFVZ7ABA4Gi$XOmu9O8SDaBexz6Zw0FCjeZJbwPP.OTK7TTZp8G/BydFXvlpHQxuuMHPzZ3IGgt3u5n73a1EkysSCendbXCDG1`

The salt added to the command allows the output to be repeatable.  (The salt algorithm is identified by the `6` and the salt is shown between the second and third `$`.)  It is better to allow `openssl` to generate random salt each time it runs.

It has also become a standard procedure to not include the password on the command line as it can be viewed by any user through the process list.  There are various ways to keep improve the security of entering the password.  One way is to take the password on the STDIN.  This is shown below.

> `openssl passwd -6 -stdin <<< ubuntu`

The above command can be used to generate the cryptographic HASH of a password that can be included in a publicly available document.  The password cannot be determined from the HASH.  In this way, the username and password information in the automated installation script with minimal security compromise.

The password(s) in this repository is not `ubuntu` and should not ever appear in the repository.

The `user-data` file also adds the ROS repository to `apt` to allow it to be installed locally.  It also configures `sshd` and adds the running of the ROS `setup.bash` to the `/etc/bash.bashrc` so any and all users will be automatically configured for using ROS.

### `meta-data`

This file is empty at this time.  It must be present in the system, however, in order for the automated installation to work.  It can be and is empty.

### `vendor-data`

This is also a file that is requested during the boot process.  Unlike `user-data` and `meta-data` its absence will not cause an error.  If present, it can be be empty.

