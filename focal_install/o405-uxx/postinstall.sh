#!/usr/bin/env bash

#### BASIC DESKTOP INSTALLATION ####

# Update the APT database
apt update
# Upgrade everything already installed
apt upgrade -y 

# This is based on a Canonical page of how to make a desktop install from the server disk
# Convert the installation to an Ubuntu Desktop (apt)
apt install -y -qq ubuntu-desktop
# Convert the installation to an Ubuntu Desktop (snap)
snap install firefox gnome-3-38-2004 gtk-common-themes snap-store snapd-desktop-integration

#### ROS INSTALLATION ####

# Add ROS repository
echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
wget -q https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc -O - | sudo apt-key add -
apt update

# Install ROS and supporting packages
apt install -y -qq git ros-noetic-desktop-full ros-noetic-ros-control ros-noetic-ros-controllers ros-noetic-gazebo-ros-control python3-rosdep 
snap install --classic code 

#### EXTRA CWRU ROS REPOSITORIES and GAZEBO REPOSITORY ####

# Add cwru-ecse-373 repository
wget -q https://cwru-ecse-373.github.io/cwru-ecse-373.asc -O - | apt-key add -
apt-add-repository https://cwru-ecse-373.github.io/repo

# Add cwru-ecse-376 repository
wget -q https://cwru-ecse-376.github.io/cwru-ecse-376.asc -O - | apt-key add -
apt-add-repository https://cwru-ecse-376.github.io/repo

# Add Gazebo repository
# This is necessary because the ECSE 373 repository packages were built with it installed.
# It would be ideal to rebuild those packages, but not likely to happen.
wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'

# Update the apt database with the packages from the new repositories
apt update

# Install packages from new repositories
apt install -y ros-noetic-stdr-simulator ros-noetic-osrf-gear ros-noetic-ur-kinematics ros-noetic-ecse-373-ariac

#### BASIC CONFIGURAIONS ####

# Remove user list from login screen
sed -i "s/# disable-user-list/disable-user-list/g" /etc/gdm3/greeter.dconf-defaults

# Remove the first login stuff
sed -i "8i InitialSetupEnable=false" /etc/gdm3/custom.conf
mkdir /etc/skel/.config
echo "yes" >> /etc/skel/.config/gnome-initial-setup-done
mkdir /etc/skel/.config/update-notifier

# Make Python work correctly with ROS.
apt install update-alternatives
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
update-alternatives --install /usr/bin/python python /usr/bin/python3 2

#### CAMPUS GLENNAN FIFTH FLOOR COMPUTER LAB CONFIGURATIONS ####

# Logout stale users
echo '#!/usr/bin/env sh' > /etc/cron.hourly/logout_stale.sh
echo "kill -9 \`who -u | gawk '/old/ {print $6}' - \`" >> /etc/cron.hourly/logout_stale.sh

# Kill any stray ROS or Gazebo processes when logging in.
echo "killall roslaunch gzclient gzserver roscore >/dev/null 2>/dev/null & disown"  >> /etc/bash.bashrc

#### FINISH UP ####

# Update the system again for completeness
apt-get update
apt-get upgrade -y

# return 0

