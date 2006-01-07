# $Id$
#
# simsea's "I can't remember which console to type in"  plugin
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) Andrew Payne 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# bMotion_plugin_complex_wrong_console
proc bMotion_plugin_complex_wrong_console { nick host handle channel text } {
	global randomWrongConsoleReply botnick
	if {![bMotion_interbot_me_next $channel]} { 
		return 0
	}
	bMotionDoAction $channel "" "%VAR{randomWrongConsoleReply}"
	
	return 1
}
# end bMotion_plugin_complex_wrong_console

# random wrong console responses
bMotion_abstract_register "randomWrongConsoleReply"
set randomWrongConsoleReply {
	"yay! %% can't get it right"
	"why don't you tell us your password as well?"
	"try the other window"
	"try 'rm -rf /' as root"
	"Would you like a hand?"
	"idiot."
	"%% is t3h l337 h4x0R!"
}

# callbacks
# "specific" typos
bMotion_plugin_add_complex "wrong console(tm)" "^rm|^cp|^su( -)?$|^make$|^ls" 20 "bMotion_plugin_complex_wrong_console" "en"

