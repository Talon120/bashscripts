#!/bin/bash

#
# Shell script to update and harden Linux servers
#
# Created by: Talon Jones
#

# Update machine and install programs
echo "Updating and installing programs"
rm -rf harden-log
mkdir harden-log
sudo apt-get update > update.txt
sudo apt-get install nano > nano.txt

# UFW provides added security but significantly slows connection
#sudo apt-get install ufw

mv update.txt harden-log
mv nano.txt harden-log

# Create new user and add to sudo group
echo "Making new admin user.
Please enter User name without capitals or special characters:"
read input_var
sudo adduser $input_var
sudo usermod -a -G sudo $input_var

# Configure UFW
#sudo ufw allow ssh
#sudo ufw allow http
echo "Enter desired SSH port (1000-60000 recommended):"
read port_var
#sudo ufw allow $port_var
#sudo ufw enable
#sudo ufw status verbose

# Configure root login and update SSH port
sudo sed -i -e "/Port/c\Port $port_var" /etc/ssh/sshd_config
sudo sed -i -e "/Protocol/c\Protocol 2" /etc/ssh/sshd_config
sudo sed -i -e "s/\<PermitRootLogin yes\>/PermitRootLogin no/" /etc/ssh/sshd_config

# Restart SSH
sudo /etc/init.d/ssh restart
