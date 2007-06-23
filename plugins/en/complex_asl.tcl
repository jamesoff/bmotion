# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "asl" {\ma/?s/?l\??\M} 100 bMotion_plugin_complex_asl "en"
  
proc bMotion_plugin_complex_asl { nick host handle channel text } {
  if {[bMotionTalkingToMe $text] || [rand 2]} {
    set age [expr [rand 20] + 13]
    global bMotionInfo
    bMotionDoAction $channel $nick "%%: $age/$bMotionInfo(gender)/%VAR{locations}"
    return 1
  }
  return 0
}
