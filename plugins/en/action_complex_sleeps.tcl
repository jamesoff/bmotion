#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "sleeps" "^(falls asleep on|dozes off on|snoozes on|sleeps on) %botnicks" 100 bMotion_plugin_complex_action_sleeps "en"

proc bMotion_plugin_complex_action_sleeps { nick host handle channel text } {
  if [bMotionLike $nick $host] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{rarrs}"
    bMotionGetHorny
    bMotionGetHappy
    bMotionGetUnLonely
    driftFriendship $nick 1
  } else {
    frightened $nick $channel
    bMotionGetUnHappy
    driftFriendship $nick -1
  }
  return 1
}
