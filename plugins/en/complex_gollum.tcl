## bMotion plugin: gollum
#
# 	$Id$	
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "gollum" "precious" 50 bMotion_plugin_complex_gollum "en"

proc bMotion_plugin_complex_gollum { nick host handle channel text } {
    bMotion_putloglev 2 * "bMotion: run complex_gollum,"
    if {![bMotion_interbot_me_next $channel]} { 
	bMotion_putloglev 4 * "bMotion: would have run gollum, but not my turn"
	return 0 
    }
    bMotion_putloglev 4 * "bMotion: my turn when running complex_gollum"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{gollums}"
    return 0 #this allows us to still respond, right?
  }
}


