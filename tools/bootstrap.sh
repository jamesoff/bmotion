#!/bin/bash

# This script bootstraps a plain machine into having eggdrop and bmotion installed

if [ -f /usr/bin/apt-get ]; then
	echo -e '\E[34mBMOTION: Updating system and installing packages...'
	tput sgr0
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get install git python tcl8.5-dev gcc redis-server
fi

if [ -d ~/eggdrop ]; then
	echo ~/eggdrop already exists
	echo Please move it out of the way manually first!
	exit
fi

echo -e '\E[34mBMOTION: Preparing eggdrop directory'
tput sgr0

mkdir -p ~/eggdrop/src && cd ~/eggdrop/src || exit 2

echo -e '\E[34mBMOTION: Fetching eggdrop...'
tput sgr0

[ -f eggdrop1.6.21.tar.bz2 ] || wget ftp://ftp.eggheads.org/pub/eggdrop/source/1.6/eggdrop1.6.21.tar.bz2 || exit 2

echo -e '\E[34mBMOTION: Unpacking and configuring eggdrop...'
tput sgr0

tar xf eggdrop1.6.21.tar.bz2 || exit 2
cd eggdrop1.6.21 || exit 2
./configure || exit 2
make config || exit 2

echo -e '\E[34mBMOTION: Building eggdrop...'
tput sgr0

make || exit 2

echo -e '\E[34mBMOTION: Installing eggdrop...'
tput sgr0
make install || exit 2

echo -e '\E[34mBMOTION: Installing bmotion...'
tput sgr0
cd ../../scripts || exit 2
git clone https://github.com/jamesoff/bmotion.git || exit 2
[ -L /usr/local/bin/bmotion ] || sudo ln -s ~/eggdrop/scripts/bmotion/tools/bmotion.py /usr/local/bin/bmotion
[ -d bmotion/local ] || mkdir bmotion/local
cp bmotion/modules/settings.sample.tcl bmotion/local/settings.tcl

echo -e '\E[34mBMOTION: complete'
tput sgr0

echo Use the /usr/local/bin/bmotion script to configure.
echo You may want to check your EDITOR variable is set to something suitable.
echo
echo "You need to edit eggdrop.conf and settings.tcl (bmotion edit)"
echo "You probably want to add eggdrop to crontab to auto-start (bmotion cron)"

