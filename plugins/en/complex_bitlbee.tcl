## bMotion plugin: bitlbee stuff
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "bitlbee-init" "Welcome to the BitlBee gateway!" 100 bMotion_plugin_complex_bitlbee1 "en"
bMotion_plugin_add_complex "bitlbee-newuser" "Message from unknown" 100 bMotion_plugin_complex_bitlbee2 "en"
bMotion_plugin_add_complex "bitlbee-discon" "Logged out: Disconnected." 100 bMotion_plugin_complex_bitlbee3 "en"

proc bMotion_plugin_complex_bitlbee1 { nick host handle channel text } {
	#we've connected to bitlbee

	if [bMotion_setting_get "bitlbee"] {
		#login to accounts
		putserv "PRIVMSG #bitlbee :account add oscar 320543426 startrek login.icq.com"
		putserv "PRIVMSG #bitlbee :account on 320543426"
		return 1
	}
	return 0
}

proc bMotion_plugin_complex_bitlbee2 { nick host handle channel text } {
	#Message from unknown ICQ handle 1094325
	if [bMotion_setting_get "bitlbee"] {
		#add this user
		regexp "Message from unknown .+ handle (.+):" $text matches h
		putserv "PRIVMSG #bitlbee :add 0 $h"
		putserv "PRIVMSG #bitlbee :$h: sorry, what?"
		bMotion_putloglev d * "met new bitlbee user $h"
		return 1
	}
}

proc bMotion_plugin_complex_bitlbee3 { nick host handle channel text } {
	#we disconnected
	if [bMotion_setting_get "bitlbee" {
		#reconnect
		putserv "PRIVMSG $channel :account on 0"
		return 1
	}
}
