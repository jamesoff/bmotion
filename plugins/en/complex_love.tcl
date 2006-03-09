## bMotion Module: love
#
# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "love" "(i )?(think )?(you are|you're )?(love|luv|wov|wuv|luvly|lovely)( you)? %botnicks" 100 bMotion_plugin_complex_love "en"

proc bMotion_plugin_complex_love { nick host handle channel text } {
  if {![bMotionLike $nick $host]} {
    frightened $nick $channel
    return 1
  }

  driftFriendship $nick 4

  if {$mood(happy) < 15 && $mood(lonely) < 5} {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{loveresponses}"
    bMotionGetHappy
    bMotionGetUnlonely
		bMotion_plugins_settings_set "system" "lastdonefor" $channel "" $nick
    return 1
  } else {
    bMotionDoAction $channel "" "hehe, want to go out on a date someplace? :)"
    set mood(happy) [expr $mood(happy) - 10]
		bMotion_plugins_settings_set "system" "lastdonefor" $channel "" $nick
    return 1
  }
}
