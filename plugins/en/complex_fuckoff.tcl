## bMotion plugin: fuck off
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

bMotion_plugin_add_complex "fuckoff" "^fuck off,?;? %botnicks" 90 bMotion_plugin_complex_fuckoff "en"

proc bMotion_plugin_complex_fuckoff { nick host handle channel text } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{fuckOffs}"
  puthelp "NOTICE $nick :If you want me to shut up, tell me to shut up|be quiet|go away in a channel."
  bMotionGetLonely
  bMotionGetSad
  driftFriendship $nick -3
  return 1
}

