## bMotion plugin: blblbl
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

bMotion_plugin_add_complex "blbl" "bl{2,}" 50 bMotion_plugin_complex_blbl "en"

proc bMotion_plugin_complex_blbl { nick host handle channel text } {
    bMotionGetHorny
    bMotionGetHappy
    if {![bMotion_interbot_me_next $channel]} { return 0 }
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{rarrs}"
    return 1
  }
}