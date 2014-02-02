#!/bin/bash

# This script bootstraps a plain machine into having eggdrop and bmotion installed

# Pass "ec2" on the command line to do system-type things like apt-get installs and MOTD
# OR pass "nobuild" on the command line to add bmotion to an existing eggdrop

if [ "$1" == "ec2" ]; then
	echo -e '\E[31mBMOTION: Running in ec2 mode'
	tput sgr0
	EC2=1
else
	EC2=0
fi

if [ "$1" == "nobuild" ]; then
	echo -e '\E[31mBMOTION: Running in nobuild mode: not installing eggdrop'
	tput sgr0
	BUILD=0
else
	BUILD=1
fi

if [ "$1" == "ec2prep" ]; then
	echo -e '\E[31mBMOTION: RUNNING IN EC2 PREP MODE'
	echo
	echo "This will destroy ssh host keys and the authorized_hosts file!"
	tput sgr0
	echo You will no longer be able to log in to this instance.
	echo
	echo Please type 'kerboom' to continue
	read MOO
	if [ ! "$MOO" == "kerboom" ]; then
		echo phew!
		exit
	fi
	echo Prepping to become an AMI...
	for i in ssh_host_dsa_key ssh_host_dsa_key.pub ssh_host_key ssh_host_key.pub ssh_host_rsa_key ssh_host_rsa_key.pub ssh_host_ecdsa_key ssh_host_ecdsa_key.pub; do
		echo Removing $i
		sudo rm /etc/ssh/$i 
	done
	
	echo Looking for authorized_keys files...
	sudo find /home -name authorized_keys -print -delete

	echo Deleting history files...
	sudo find /home -name .bash_history -print -delete

	echo All done!
	exit
fi

if [ "$BUILD$EC2" == "10" ]; then
	echo "This script will download and install eggdrop, and then install bmotion."
	echo "Everything will be installed in ~/eggdrop"
	echo
	echo "If you have problems during the build, make sure you have a working compiler"
	echo "and that you have the TCL headers installed (something like tcl8.5-dev)."
	echo "You'll also need git for bmotion to be installed."
	echo "Optionally, you should have python for the bmotion utility script."
	echo
	echo "Hit enter to continue, or Ctrl-C to abort"
	read
fi

if [ "$EC2" == "1" ]; then
	if [ -f /usr/bin/apt-get ]; then
		echo -e '\E[34mBMOTION: Updating system and installing packages...'
		tput sgr0
		sudo apt-get update
		sudo apt-get upgrade
		sudo apt-get install git python tcl8.5-dev gcc redis-server telnet
	fi

	echo -e '\E[34mBMOTION: Updating MOTD...'
	tput sgr0
	TEMPFILE=`mktemp`
	cat << _MOTD > $TEMPFILE
Welcome to bMotion.

Your bot is in ~/eggdrop
bMotion is in ~/eggdrop/scripts/bmotion

-- SETUP
You should edit ~/eggdrop/scripts/bmotion/local/settings.tcl as well
as ~/eggdrop/eggdrop.conf

You can use "bmotion edit -f {eggdrop,bmotion}" to do that.

You may want to uncomment the "listen" line so you bot listens for
telnet connections. The default AWS firewall will mean you can only
connect to telnet locally so you should be safe. DCC chat will not
work until you configure ports etc!

Remember to start your bot with "./eggdrop -m" the first time.

Once on the partyline, use ".chanset #channel +bmotion" to enable
bMotion on desired channels.

-- STARTUP
Your bot will not automatically start until you configure crontab.

You can use "bmotion cron -i" to do that.

-- UPDATES
You can update bMotion with:
  cd eggdrop/scripts/bmotion && git pull

You can use "bmotion update" to do that.

-- HELP
Come to #bmotion on EFNet for support.


-- FUN
Have fun :)


JamesOff/jms
_MOTD
	sudo mv $TEMPFILE /etc/motd

	if [ -d ~/eggdrop ]; then
		echo ~/eggdrop already exists
		echo Please move it out of the way manually first!
		exit
	fi

fi

if [ "$BUILD" == "1" ] ; then
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
fi

echo -e '\E[34mBMOTION: Installing bmotion...'
tput sgr0
cd ~/eggdrop/scripts || exit 2
git clone https://github.com/jamesoff/bmotion.git || exit 2
[ -L /usr/local/bin/bmotion ] || sudo ln -s ~/eggdrop/scripts/bmotion/tools/bmotion.py /usr/local/bin/bmotion
[ -d bmotion/local ] || mkdir bmotion/local
cp bmotion/modules/settings.sample.tcl bmotion/local/settings.tcl

grep bMotion.tcl ../eggdrop.conf > /dev/null
if [ "$?" == "1" ]; then
	echo Adding bMotion to eggdrop.tcl
	echo "source scripts/bmotion/bMotion.tcl" >> ../eggdrop.conf
fi

grep GENDER userinfo.tcl > /dev/null
if [ "$?" == "1" ]; then
	echo Updating userinfo.tcl
	sed -i "s/PHONE ICQ/PHONE ICQ GENDER IRL/" userinfo.tcl
fi

echo -e '\E[34mBMOTION: complete'
tput sgr0

echo Use the /usr/local/bin/bmotion script to configure.
echo You may want to check your EDITOR variable is set to something suitable.
echo
echo "You need to edit eggdrop.conf and settings.tcl (bmotion edit)"
echo "You probably want to add eggdrop to crontab to auto-start (bmotion cron)"

