#!/bin/bash
 
# Greeting
clear
echo "Please enter your Case network password a second time to mount your CSE home folder. This will be located in your home folder under the 'LabHome' directory."
 
# Ask user for password via terminal or gui
if [ -n "$DISPLAY" ];
then
        exit 0
else
        read -s -p "Password: " user_password
fi
 
# Attempt the mount, if it fails notify to contact support
mount_command="/usr/bin/mountHome.sh $user_password"
 
if eval $mount_command
then
        echo -e "\n"
        exit 0
else
 
        echo "Unable to mount your home directory.  Please contact the help desk at 216-368-4357 to report this error to the Engineering Computing Group."
        echo "Press any key to exit"
        read -n 1
 
fi
 
# Unset password variable for security
unset user_password

