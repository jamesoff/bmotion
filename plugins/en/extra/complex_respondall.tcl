# This plugin will respond to anything with the bot's nick in!
#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "zzzz_respondall" "%botnicks" 100 "bMotion_plugin_complex_respondall" "en"


#################################################################################################################################
# Declare plugin functions

proc bMotion_plugin_complex_respondall { nick host handle channel text } {
   bMotionDoAction $channel $nick "%VAR{respondalls}"

	 # we return 0 here to avoid incrementing the flood counter for the user
   return 0
}

bMotion_abstract_register "respondalls" {
	"%VAR{randomStuff}"
	"%VAR{randomReplies}"
}

