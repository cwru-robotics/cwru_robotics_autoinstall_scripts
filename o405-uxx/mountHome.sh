#!/bin/bash
 
#Check for input arguments
if [ -z "$1" ]
then
        echo "No password supplied"
        exit 0
else
        user_password=$1
fi
 
# Check if already mounted
check_mounted_var="$(mount | grep /home/$USER/LabHome -c)"
 
if [ "$check_mounted_var" -gt "0" ]
then
        exit 0
fi
 
# Create home mount point if it does not exist
mkdir -p ~/LabHome
 
# Attempt the mount
mount_command="echo $user_password | sshfs -o idmap=user -o password_stdin $USER@labhomes.case.edu:/ ~/LabHome"
 
# Clear user password from memory and logs
history -d 1
unset user_password
 
# If mount fails return -1
if eval $mount_command
then
        exit 0
else
        exit -1
fi

