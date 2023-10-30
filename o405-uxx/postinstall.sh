#!/usr/bin/env bash

echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
apt update

apt install ubuntu-desktop git ros-noetic-desktop-full python3-rosdep nfs-common sssd-ad sssd sssd-tools libnss-sss libpam-sss realmd samba-common-bin adcli sssd-ldap ldap-utils sssd-ldap krb5-user sshfs

snap install firefox gnome-3-38-2004 gtk-common-themes snap-store snapd-desktop-integration
snap install --classic code 


# Add saabd drive
mkdir /mgc
echo "saabd.eecs.cwru.edu:/mgc        /mgc    nfs     rsize=8192,wsize=8192,timeo=14,intr" >> /etc/fstab

# Remove user list from login screen
sed -i "s/# disable-user-list/disable-user-list/g" /etc/gdm3/greeter.dconf-defaults

# Remove the first login stuff
echo "InitialSetupEnable=false" >> /etc/gdm3/custom.conf

# Add logout script
# Update the logout script everytime in case it changed
echo "cp /etc/skel/.bash_logout ~/" >> /etc/bash.bashrc
# Remove the build directory for ariac (hopefully obsolete)
echo "rm -rf /tmp/ariac >/dev/null 2>/dev/null & disown" >> /etc/skel/.bash_logout
# Make sure every thing ROS (and Gazebo) related is killed when logging out
echo "killall roslaunch roscore gzserver gzclient >/dev/null 2>/dev/null & disown" >> /etc/skel/.bash_logout

# This is temporary until individual accounts work
echo "rm -rf ~/.ssh/*" >> /etc/skel/.bash_logout
echo "rm -rf ~/.git" >> /etc/skel/.bash_logout
echo "rm -rf ~/*_ws" >> /etc/skel/.bash_logout

# Logout stale users
echo "#!/usr/bin/env sh" > /etc/cron.hourly/logout_stale.sh
echo "kill -9 `who -u | gawk '/old/ {print $6}' - `" >> /etc/cron.hourly/logout_stale.sh

# Update the system
apt-get update
apt-get upgrade -y

# Add LabHome stuff (seems broken)
wget -O /etc/xdg/autostart/mounthomegui.desktop http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mounthomegui.desktop
wget -O /usr/bin/mountHomePrompt.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHomePrompt.sh
wget -O /usr/bin/mountHomeGUI.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHomeGUI.sh
wget -O /usr/bin/mountHome.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHome.sh
chmod ugo+x /usr/bin/mountHome*.sh

echo "/usr/bin/mountHomePrompt.sh" /etc/skel/.profile

wget -O /etc/cron.hourly/logout_stale.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/logout_stale.sh
chmod u+x /usr/cron.hourly/logout_stale.sh

# Build custom ROS stuff for now
mkdir -p ros_ws/src
cd ros_ws/src
git clone https://github.com/cwru-eecs-275/stdr_simulator.git
git clone https://github.com/cwru-eecs-373/cwru_ariac_2019.git
git clone https://github.com/cwru-eecs-373/ecse_373_ariac.git

cd ../

source /opt/ros/noetic/setup.bash

rosdep init
rosdep update

rosdep install --from-paths src --ignore-src -r -y

catkin_make

catkin_make -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic install
