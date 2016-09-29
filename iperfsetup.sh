#!/bin/sh
#
# Program name:	iperfsetup.sh
# Created by:	Talon Jones
# Creation date:29 Sept. 2016
# Purpose:	Bash script to install iperf3 and all dependent libraries.
# Note:		iPerf directory will be cloned to current directory.

echo "y" | sudo apt-get update
echo "y" | sudo apt-get install git make
git clone https://github.com/esnet/iperf
cd iperf
sudo ./configure
sudo make
sudo make install
sudo apt-get install libz1 libbz2-1.0 libstdc++6
sudo ldconfig
