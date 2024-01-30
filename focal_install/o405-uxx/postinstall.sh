#!/usr/bin/env bash

#### BASIC DESKTOP INSTALLATION STUFF ####

# Update the APT database
apt update
# Upgrade everything already installed
apt upgrade -y 

# This is based on a Canonical page of how to make a desktop install from the server disk
# Convert the installation to an Ubuntu Desktop (apt)
apt install -y -qq ubuntu-desktop
# Convert the installation to an Ubuntu Desktop (snap)
snap install firefox gnome-3-38-2004 gtk-common-themes snap-store snapd-desktop-integration

#### CAMPUS COMPUTER PACKAGES ####

# # Install things required for campus computers
# apt install -y -qq nfs-common sssd-ad sssd sssd-tools libnss-sss libpam-sss realmd samba-common-bin adcli sssd-ldap ldap-utils sssd-ldap krb5-user sshfs

#### ROS INSTALLATION ####

# Add ROS repository
echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
apt update

# Install ROS and supporting packages
apt install -y -qq git ros-noetic-desktop-full python3-rosdep 
snap install --classic code 

#### EXTRA ROS REPOSITORIES ####

# Add cwru-ecse-376 repository
wget -q https://cwru-ecse-376.github.io/cwru-ecse-376.asc -O - | apt-key add -
apt-add-repository https://cwru-ecse-376.github.io/repo
apt update

# Install stuff from new repository
apt install -y -qq ros-noetic-stdr-simulator

#### BASIC CONFIGURAIONS ####

# Remove user list from login screen
sed -i "s/# disable-user-list/disable-user-list/g" /etc/gdm3/greeter.dconf-defaults

# Remove the first login stuff
sed -i "8i InitialSetupEnable=false" /etc/gdm3/custom.conf
mkdir /etc/skel/.config
echo "yes" >> /etc/skel/.config/gnome-initial-setup-done
mkdir /etc/skel/.config/update-notifier


#### CAMPUS GLENNAN FIFTH FLOOR COMPUTER LAB CONFIGURATIONS ####

# # Logout stale users
# echo '#!/usr/bin/env sh' > /etc/cron.hourly/logout_stale.sh
# echo "kill -9 `who -u | gawk '/old/ {print $6}' - `" >> /etc/cron.hourly/logout_stale.sh

# # Add logout script
# # Update the logout script everytime in case it changed
# echo "cp /etc/skel/.bash_logout ~/" >> /etc/bash.bashrc
# # Remove the build directory for ariac (hopefully obsolete)
# echo "rm -rf /tmp/ariac >/dev/null 2>/dev/null & disown" >> /etc/skel/.bash_logout
# # Make sure every thing ROS (and Gazebo) related is killed when logging out
# echo "killall roslaunch roscore gzserver gzclient >/dev/null 2>/dev/null & disown" >> /etc/skel/.bash_logout

# # # Add saabd drive
# # mkdir /mgc
# echo "# saabd.eecs.cwru.edu:/mgc        /mgc    nfs     rsize=8192,wsize=8192,timeo=14,intr" >> /etc/fstab


#### TEMPORARY FIXES FOR GLENNAN FIFTH FLOOR ####

# # This is temporary until individual accounts work
# echo "rm -rf ~/.ssh/*" >> /etc/bash.bashrc
# echo "rm -rf ~/.git" >> /etc/bash.bashrc
# echo "rm -rf ~/*_ws" >> /etc/bash.bashrc

# # Add LabHome stuff (seems broken)
# wget -O /etc/xdg/autostart/mounthomegui.desktop http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mounthomegui.desktop
# wget -O /usr/bin/mountHomePrompt.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHomePrompt.sh
# wget -O /usr/bin/mountHomeGUI.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHomeGUI.sh
# wget -O /usr/bin/mountHome.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHome.sh
# chmod ugo+x /usr/bin/mountHome*.sh

# echo "/usr/bin/mountHomePrompt.sh" /etc/skel/.profile

# wget -O /etc/cron.hourly/logout_stale.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/logout_stale.sh
# chmod ugo+x /usr/cron.hourly/logout_stale.sh


#### FINISH UP ####

# Update the system again for completeness
apt-get update
apt-get upgrade -y


# apt-get install ./ros-noetic-*

# # Build custom ROS stuff for now
# mkdir -p ros_ws/src
# cd ros_ws/src
# git clone https://github.com/cwru-eecs-275/stdr_simulator.git
# git clone https://github.com/cwru-eecs-373/cwru_ariac_2019.git
# git clone https://github.com/cwru-eecs-373/ecse_373_ariac.git

# cd ../

# source /opt/ros/noetic/setup.bash

# rosdep init
# rosdep update

# rosdep install --from-paths src --ignore-src -r -y

# catkin_make -j 4 -l 4.0 -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic 

# sudo bash -c "source /opt/ros/noetic/setup.bash; catkin_make -j 4 -l 4.0 -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic install"


# return 0

