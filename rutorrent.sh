#!/bin/bash

# Name: 	rutorrent.sh
# Purpose:	Automatically installs rTorrent, libTorrent, and XMLRPC in current
#		directory. Then secures ruTorrent and '/download' in '/var/www/'.
# Created by:	Talon Jones
# Created on:	Oct. 8, 2013

# Prompt user for yes/no if they want to continue
while true; do
    read -p "This program will remove current settings for Apache and replace them with custom settings.
It will also modify rc.local to start rTorrent on boot.
Do you wish to continue? (Y/N):" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Update machine and install required dependencies
echo "Updating and installing dependencies"
apt-get update
sudo apt-get install subversion build-essential automake libtool libcppunit-dev libcurl3-dev libsigc++-2.0-dev unzip unrar-free curl libncurses-dev
apt-get install apache2 php5 php5-cli php5-curl

# Get and enable SCGI
echo "Installing and enabling SCGI"
apt-get install libapache2-mod-scgi
ln -s /etc/apache2/mods-available/scgi.load /etc/apache2/mods-enabled/scgi.load


# Make 'install' directory in current location. Download and install
# latest stable  XMLRPC release to 'install'.

# Saves current folder location to variable
echo "Creating 'install' directory"
currentdir=${PWD}
mkdir $currentdir/install;cd $currentdir/install

# Saves URL of current stable XMLRPC to variable
echo "Downloading and installing latest stable release of XMLRPC"
REPOS=http://svn.code.sf.net/p/xmlrpc-c/code/stable
svn checkout $REPOS xmlrpc-c
cd xmlrpc-c
./configure --disable-cplusplus
make
make install


# Return to 'install' directory and download libtorrent-0.13.2
# tar ball. Then unpack and proceed to install.

cd $currentdir/install

# Save URL of stable libtorrent version to variable
echo "Downloading and installing latest stable release of libtorrent"
libtor=http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.2.tar.gz
wget $libtor
tar xvf libtorrent-0.13.2.tar.gz
cd libtorrent-0.13.2
./autogen.sh
./configure
make
make install


# Return to 'install' directory and download rtorrent-0.9.2
# tar ball. Then unpack and proceed to install.

cd $currentdir/install

# Save URL of stable rtorrent version to variable
echo "Downloading and installing latest stable release of rtorrent"
rtor=http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.2.tar.gz
wget $rtor
tar xvf rtorrent-0.9.2.tar.gz
cd rtorrent-0.9.2
./autogen.sh
./configure --with-xmlrpc-c
make
make install
ldconfig


# Create '.session' and 'watch' directories in current directory
# rTorrent folder and 'download' directory in '/var/www/'

echo "Creating required rtorrent folders"
mkdir $currentdir/rtorrent
mkdir $currentdir/rtorrent/.session
mkdir $currentdir/rtorrent/watch
mkdir /var/www/download


# Create .rtorrent.rc file in current directory  using custom
# directories

echo "Creating .rtorrent.rc with custom settings in current directory"
cd $currentdir
sudo touch .rtorrent.rc

echo "# Remember to uncomment the options you wish to enable.
#
# Based on original .seeder1rent.rc file from http://libtorrent.rakshasa.no/
# Modified by Lemonberry for rtGui http://rtgui.googlecode.com/
#
# Modified by Talon


# Maximum and minimum number of peers to connect to per torrent.
#min_peers = 40
#max_peers = 250

# Same as above but for seeding completed torrents (-1 = same as downloading)
min_peers_seed = -1
max_peers_seed = -1

# Maximum number of simultanious uploads per torrent.
max_uploads = 50

# Global upload and download rate in KiB. \"0\" for unlimited.
download_rate = 0
upload_rate = 0

# Default directory to save the downloaded torrents.
directory = /var/www/download

# Default session directory. Make sure you don't run multiple instance
# of seeder1rent using the same session directory. Perhaps using a
# relative path?
session = $currentdir/rtorrent/.session

# Watch a directory for new torrents, and stop those that have been
# deleted.
schedule = watch_directory,5,5,load_start=$currentdir/rtorrent/watch/*.torrent
schedule = untied_directory,5,5,stop_untied=

# Close torrents when diskspace is low. */
schedule = low_diskspace,5,60,close_low_diskspace=100M

# Stop torrents when reaching upload ratio in percent,
# when also reaching total upload in bytes, or when
# reaching final upload ratio in percent.
# example: stop at ratio 2.0 with at least 200 MB uploaded, or else ratio 20.0
#schedule = ratio,60,60,stop_on_ratio=200,200M,2000

# When the torrent finishes, it executes \"mv -n <base_path> ~/Download/\"
# and then sets the destination directory to \"~/Download/\". (0.7.7+)
# on_finished = move_complete,\"execute=mv,-u,\$d.get_base_path=,$currentdir/download/complete/ ;d.set_directory=$currentdir/download/complete/\"

# The ip address reported to the tracker.
#ip = 127.0.0.1
#ip = rakshasa.no

# The ip address the listening socket and outgoing connections is
# bound to.
#bind = 127.0.0.1
#bind = rakshasa.no

# Port range to use for listening.
port_range = 55995-56000

# Start opening ports at a random position within the port range.
#port_random = yes

scgi_port = 127.0.0.1:5000

# Check hash for finished torrents. Might be usefull until the bug is
# fixed that causes lack of diskspace not to be properly reported.
#check_hash = no

# Set whetever the client should try to connect to UDP trackers.
#use_udp_trackers = no

# Alternative calls to bind and ip that should handle dynamic ip's.
#schedule = ip_tick,0,1800,ip=rakshasa
#schedule = bind_tick,0,1800,bind=rakshasa

# Encryption options, set to none (default) or any combination of the following:
# allow_incoming, try_outgoing, require, require_RC4, enable_retry, prefer_plaintext
#
# The example value allows incoming encrypted connections, starts unencrypted
# outgoing connections but retries with encryption if they fail, preferring
# plaintext to RC4 encryption after the encrypted handshake
#
encryption = allow_incoming,enable_retry,prefer_plaintext

# Enable DHT support for trackerless torrents or when all trackers are down.
# May be set to \"disable\" (completely disable DHT), \"off\" (do not start DHT),
# \"auto\" (start and stop DHT as needed), or \"on\" (start DHT immediately).
# The default is \"off\". For DHT to work, a session directory must be defined.
#
dht = disable

# UDP port to use for DHT.
#
# dht_port = 6881

# Enable peer exchange (for torrents not marked private)
#
peer_exchange = no

#
# Do not modify the following parameters unless you know what you're doing.
#

# Hash read-ahead controls how many MB to request the kernel to read
# ahead. If the value is too low the disk may not be fully utilized,
# while if too high the kernel might not be able to keep the read
# pages in memory thus end up trashing.
#hash_read_ahead = 10

# Interval between attempts to check the hash, in milliseconds.
#hash_interval = 100

# Number of attempts to check the hash while using the mincore status,
# before forcing. Overworked systems might need lower values to get a
# decent hash checking rate.

# before forcing. Overworked systems might need lower values to get a
# decent hash checking rate.
#hash_max_tries = 10

# Max number of files to keep open simultaniously.
#max_open_files = 128

# Number of sockets to simultaneously keep open.
#max_open_sockets = <no default>

# Example of scheduling commands: Switch between two ip's every 5
# seconds.
#schedule = \"ip_tick1,5,10,ip=torretta\"
#schedule = \"ip_tick2,10,10,ip=lampedusa\"

# Remove a scheduled event.
#schedule_remove = \"ip_tick1\"

" >> .rtorrent.rc


# Return to 'install' directory and download rutorrent-3.5
# and plugins-3.5 tar ball. Then unpack and proceed to install.

cd $currentdir/install

# Save URL of rutorrent-3.5 to variable
echo "Downloading and installing rutorrent-3.5"
rutor=https://rutorrent.googlecode.com/files/rutorrent-3.5.tar.gz
wget $rutor
tar xvf rutorrent-3.5.tar.gz
mv rutorrent /var/www

# Save URL of rutorrent plugin-3.5 to variable
echo "Downloading rutorrent plugin-3.5"
ruplug=https://rutorrent.googlecode.com/files/plugins-3.5.tar.gz
wget $ruplug
tar xvf plugins-3.5.tar.gz
mv plugins /var/www/rutorrent
rm -rf /var/www/rutorrent/plugins/darkpal
chown -R www-data:www-data /var/www/rutorrent


# Secure /rutorrent with username and password
#

echo "Enabling security for /var/www"
a2enmod ssl
a2enmod auth_digest
a2enmod scgi

# Get security certificate valid for 365 days
echo "Creating security certificate"
openssl req $@ -new -x509 -days 365 -nodes -out /etc/apache2/apache.pem -keyout /etc/apache2/apache.pem
chmod 600 /etc/apache2/apache.pem

# Create user and password for login
echo "Creating rutorrent login info"
echo "Pleae enter desired username: "
read input_var
echo "Please enter desired password: "
sudo htdigest -c /etc/apache2/passwords login $input_var

# Create new 'default' file to contain '/rutorrent' and '/download' permissions
echo "Securing '/rutorrent' and '/download' with login information"
cd /etc/apache2/sites-available/
sudo rm -rf default
sudo touch default

echo "<VirtualHost *:80>
ServerAdmin webmaster@localhost

DocumentRoot /var/www/
<Directory />
Options FollowSymLinks
AllowOverride None
</Directory>
<Directory /var/www/>
Options Indexes FollowSymLinks MultiViews
AllowOverride None
Order allow,deny
allow from all
</Directory>

ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
<Directory \"/usr/lib/cgi-bin\">
AllowOverride None
Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
Order allow,deny
Allow from all
</Directory>

ErrorLog /var/log/apache2/error.log

# Possible values include: debug, info, notice, warn, error, crit,
# alert, emerg.
LogLevel warn

CustomLog /var/log/apache2/access.log combined

Alias /doc/ \"/usr/share/doc/\"
<Directory \"/usr/share/doc/\">
Options Indexes MultiViews FollowSymLinks
AllowOverride None
Order deny,allow
Deny from all
Allow from 127.0.0.0/255.0.0.0 ::1/128
</Directory>

<Location /rutorrent>
AuthType Digest
AuthName \"login\"
AuthDigestDomain /var/www/rutorrent/ http://127.0.0.1/rutorrent

AuthDigestProvider file
AuthUserFile /etc/apache2/passwords
Require valid-user
SetEnv R_ENV \"/var/www/rutorrent\"
</Location>

<Location /download>
AuthType Digest
AuthName \"login\"
AuthDigestDomain /var/www/download/ http://127.0.0.1/download

AuthDigestProvider file
AuthUserFile /etc/apache2/passwords
Require valid-user
SetEnv R_ENV \"/var/www/download\"
</Location>

</VirtualHost>

" >> default

# Enable ssl and restart Apache
echo "Restarting Apache"
a2ensite default-ssl
/etc/init.d/apache2 reload
echo "Apache restarted"


# Install screen and start rTorrent, then modify rc.local
# to start rTorrent on boot. Then change ownership of 
# '/var/www/rutorrent' and '/var/www/download'

echo "Installing screen"
apt-get install screen

# Start rTorrent in detached shell using screen
echo "Starting rtorrent"
screen -fa -d -m rtorrent

# Modify rc.local
sudo touch temp
echo "Modifying rc.local"
sudo sed "$ i\sleep 10" /etc/rc.local >> temp
sudo sed "$ i\/etc/init.d/apache2 reload" temp >> temp
sudo sed "$ i\screen -fa -d -m rtorrent" temp >> tempsudo mv -f temp /etc/rc.local
echo "Modification complete"

# Change ownership of new directories in '/var/www/'
echo "Changing ownership of new directories"
sudo chown www-data:www-data /var/www/rutorrent
sudo chown www-data:www-data /var/www/download

# Installation of ruTorrent complete
servip="$(hostname -i)"
echo "Installation of ruTorrent completed.
To access, simply go to $servip/rutorrent and login.
To access downloaded content, go to $servip/download"
