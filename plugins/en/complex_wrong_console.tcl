# $Id$
#
# simsea's "I can't remember which console to type in"  plugin

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
  if {![bMotion_interbot_me_next $channel]} { return 0 }
	bMotionDoAction $channel "" "%VAR{randomWrongConsoleReply}"
	
	#log this action
	bMotion_putloglev d * "bMotion: (wrong console(tm)) $nick couldn't remember which window to type in"
}
# end bMotion_plugin_complex_wrong_console

# random wrong console responses
bMotion_abstract_register "randomWrongConsoleReply"

# callbacks
# "specific" typos
bMotion_plugin_add_complex "wrong console(tm)" "^rm|^cp|^su( -)?$|^make$|^ls" 20 "bMotion_plugin_complex_wrong_console" "en"

