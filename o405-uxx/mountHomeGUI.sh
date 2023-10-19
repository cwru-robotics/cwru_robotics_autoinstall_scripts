#!/bin/bash

# Ask user for password via gui
user_password=$(zenity \
--entry \
--title="Enter your password" \
--text="Please enter your Case network password\na second time to mount your CSE home folder.\nThis will be located in your home folder\nunder the 'LabHome' directory." \
--hide-text)

/usr/bin/mountHome.sh "$user_password"

# Unset password variable for security
unset user_password
