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
    if {![bMotion_interbot_me_next $channel]} { return 0 }
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{gollums}"
    return 1
  }
}


