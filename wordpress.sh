#!/bin/bash

#
# Shell script to install wordpress
#
# Created by: Talon Jones
#

# Save current directory to variable
currentdir=${PWD}

# Get latest install of Apache2
sudo apt-get install apache2

# Install MySQL version 5.1
sudo apt-get install mysql-server-5.1

# Set up MySQL
sudo mysql_install_db
sudo mysql_secure_installation

# Install PHP version 5
sudo apt-get install php5

# Install MySQL module for PHP
sudo apt-get install php5-mysql

# Install GD library for PHP
sudo apt-get install php5-gd

# Get and unpack Wordpress
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

# Remove Apache2 'index.html' and copy Wordpress contents to '/var/www/'
sudo rm -f /var/www/index.html
sudo cp -r $currentdir/wordpress/* /var/www/

# Make copy of Apache2 config file
cp /etc/apache2/apache2.conf $currentdir

# Add .html files to Apache2 config
echo "AddType application/x-httpd-php .html" >> /etc/apache2/apache2.conf

# Restart Apache2 for changes to take effect
sudo service apache2 restart

# Setup MySQL
touch .temptxt.txt

echo "Please enter MySQL Password > "
read -s mysqlpass

echo "CREATE DATABASE wordpress;
CREATE USER wordpressuser;
SET PASSWORD FOR wordpressuser= PASSWORD(\"$mysqlpass\");
GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser IDENTIFIED BY '$mysqlpass';
exit" >> .temptxt.txt

mysql -u root -p < .temptxt.txt

rm .temptxt.txt

# Create wp-config file and add MySQL settings set above
sudo cp /var/www/wp-config-sample.php /var/www/wp-config.php

sudo sed -i 's/database_name_here/wordpress/g' /var/www/wp-config.php
sudo sed -i 's/username_here/wordpressuser/g' /var/www/wp-config.php
sudo sed -i "s/password_here/$mysqlpass/g" /var/www/wp-config.php

# Change owner of '/var/www/' files to www-data
sudo chown -R www-data:www-data /var/www/

# Create and set ownership of .htaccess
sudo touch .htaccess
sudo chown www-data:www-data .htaccess
sudo mv -f .htaccess /var/www/

# Setup complete
echo "Wordpress Setup Complete"
