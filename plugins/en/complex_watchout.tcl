## bMotion plugin: watch out
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

bMotion_plugin_add_complex "watchout" "^%botnicks,?:? (watch out|watch it|careful|run( for (it|the hills))?|hide|duck)!?" 100 bMotion_plugin_complex_watchout "en"

proc bMotion_plugin_complex_watchout { nick host handle channel text } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{hides}"
  bMotionGetUnLonely
  driftFriendship $nick 2
  return 0
}