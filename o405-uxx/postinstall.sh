#!/usr/bin/env bash

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

# Add LabHome stuff (seems broken)
wget -O /usr/bin/mountHomePrompt.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHomePrompt.sh
wget -O /usr/bin/mountHomeGUI.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHomeGUI.sh
wget -O /usr/bin/mountHome.sh http://raw.githubusercontent.com/cwru-robotics/cwru_robotics_autoinstall_scripts/focal_install/o405-uxx/mountHome.sh
chmod ugo+x /usr/bin/mountHome*.sh

echo "/usr/bin/mountHomePrompt.sh" /etc/skel/.profile

# Build custom ROS stuff for now
mkdir -p ros_ws/src
cp ros_ws/src
git clone https://github.com/cwru-eecs-275/stdr_simulator.git
git clone https://github.com/cwru-eecs-373/cwru_ariac_2019.git

cd ../

source /opt/ros/noetic/setup.bash

rosdep init

rosdep install --from-paths-src --ignore-src -r -y

catkin_make

catkin_make -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic install
