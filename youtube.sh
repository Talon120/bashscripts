#!/bin/bash
#
# YouTube.sh
#
# Description:	Used to download and install YouTube downloader and dependencies and
#		make it easier to download.
#
# Notes:	Tested on Ubuntu 11.10, may not be compatible with others.
#		Main issue is location of aliases not being /root/.bash_aliases or
#			needing to un-comment use of '.bash_aliases' in  '.bashrc'.
#
# Created by:	Talon Jones
#

function dots() {
	while : ; do
		sleep 1s
		echo -n " ."
	done
}

function killdots() {
	kill -9 ${1} 2>/dev/null
	wait ${1} 2>/dev/null
}

# This function removes downloads and all dependencies of YouTube.sh
function remove() {

	echo ""
        # Prompt user for yes/no if they want to remove all downloads
        while true; do
            read -p "Do you wish to remove all downloads? (Y/N): " yn
            case $yn in
                [Yy]* ) sudo rm -rf  downloads && break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
            esac
        done

	# Begin removing and show progression instead of classic removal
	echo -n -e '\vRemoving Youtube-dl and dependencies.'
	dots &
	dots_pid=$!
        trap 'killdots ${dots_pid}; exit' INT TERM EXIT

	sudo rm -f /etc/profile.d/ytalias.sh
	sudo rm -f YouTubeREADME.txt
	sudo apt-get -y purge youtube-dl ffmpeg libavcodec-extra-53 expect >> .RemoveLog

	killdots ${dots_pid}
	echo -e '\nYoutube-dl and dependencies successfully removed.\v'

	exit 0
}

function clean() {
        echo ""
        # Prompt user for yes/no if they want to remove all downloads
        while true; do
            read -p "Do you wish to remove all downloads? (Y/N): " yn
            case $yn in
                [Yy]* ) sudo rm -rf  downloads/* && break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
            esac
        done

	# Prompt user for yes/no if they want to clean /var/www/youtube-dl
	while true; do
	    read -p "Do you wish to remove downloads from /var/www/youtube-dl? (Y/N): " yn
	    case $yn in
		[Yy]* ) sudo rm -rf /var/www/youtube-dl/* && break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	    esac
	done

	exit 0
}

function transfer() {
	mkdir -p /var/www/youtube-dl
	cp -r downloads/* /var/www/youtube-dl
	exit 0
}

function update() {
	sudo youtube-dl --update
}

function installation() {
	echo -n -e '\vDownloading and installing dependencies.'

	# Begin installing and show progression instead of classic install
	dots &
	dots_pid=$!
	trap 'killdots ${dots_pid}; exit' INT TERM EXIT

	sudo apt-get -y update > .InstallLog
	sudo apt-get -y install youtube-dl ffmpeg libavcodec-extra-53 expect >> .InstallLog
	sudo mkdir -p downloads >> .InstallLog
	sudo chmod u+rwx,g+rwx,o+rwx downloads

	# Create aliases for YouTube scripts
	sudo echo "
#!/bin/bash
# Aliases created by YouTube.sh
alias youtube='sudo $PWD/youtube.sh'
function mp3tube() {
	temp=\$PWD
	cd $PWD/downloads
	youtube-dl \$1 -t -x --audio-format \"mp3\"
	cd \$temp
}
alias mp3tube=mp3tube
function vidtube() {
	temp=\$PWD
	cd $PWD/downloads
	youtube-dl \$1 -t --max-quality \"mp4\"
	cd \$temp
}
alias vidtube=vidtube
function mp3tubeuser() {
	temp=\$PWD
	cd $PWD/downloads
	youtube-dl -A -citw ytuser:\$1 -t -x --audio-format \"mp3\"
	cd \$temp
}
alias mp3tubeuser=mp3tubeuser
function vidtubeuser() {
	temp=\$PWD
	cd $PWD/downloads
	youtube-dl -A -citw ytuser:\$1
	cd \$temp
}
alias vidtubeuser=vidtubeuser
function transfer() {
        sudo mkdir -p /var/www/youtube-dl
        sudo cp -r $PWD/downloads/* /var/www/youtube-dl
}
alias utubetransfer=transfer
function clean() {
	sudo rm -rf /var/www/youtube-dl/*
}
alias utubeclean=clean" > /etc/profile.d/ytalias.sh

	# Kill progression bar
	killdots ${dots_pid}
	echo -e '\nInstallation finished!\v'

	# Output usage instructions
	echo -e "\vYou can use the following commands to download YouTube videos:
	youtube <link>:		Will run this installer/remover
	mp3tube <link>:		Download video or playlist as audio only (mp3)
	vidtube <link>:		Download video or playlist as video (mp4)
	vidtubeuser <link>:	Download all videos from a user as video (mp4)
	mp3tubeuser <link>:	Download all vidoes from a user as audio (mp3)
	utubetransfer:		Copy contents of downloads folder to /var/www/youtube-dl
	utubeclean:		Removes the contents of /var/www/youtube-dl
	\vAll downloads will be downloaded to the 'downloads' folder in current directory.
	To view this again, access the YouTubeREADME.txt\v
        To enable the above commands for the first time, please enter 'source /etc/profile.d/ytalias.sh'.\v" | tee YouTubeREADME.txt
	exit 0
}

#
# Begining of main function
#
clear

while :
do

echo -n "

Running YouTube.sh by Talon Jones

Please type an option below:
	install:	Install files and create directories and commands.
	remove:		Remove all files and directories if specified.
	clean:		Cleans the 'downloads' directory and/or /var/www/youtube-dl directory of downloads.
	transfer:	Transfers all files in 'downloads' to /var/www/youtube-dl.
			(Tested on Ubuntu 11.10 server)
	update: 	Updates Youtube-dl to most recent version.
	exit:		Exits application.

Selection -> "
read option

case $option in
install) installation;;
remove) remove;;
clean) clean;;
transfer) transfer;;
update) update;;
exit) exit ;;
*) echo "\"$option\" is not valid" ;;
esac

done
