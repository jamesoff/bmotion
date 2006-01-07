## bMotion plugin: hops
#
# $Id$
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "hops" "^hops (in|on)to %botnicks'?s lap" 100 bMotion_plugin_complex_action_hops "en"

proc bMotion_plugin_complex_action_hops { nick host handle channel text } {
  if [bMotionLike $nick $host] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{rarrs}"
    bMotionGetHorny
    bMotionGetHappy
    bMotionGetUnLonely
    driftFriendship $nick 1
  } else {
    frightened $nick $channel
    driftFriendship $nick -1
  }
  return 1
}
