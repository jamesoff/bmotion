## bMotion plugin: pinch
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "pinch" "^(steals|pinches|theives|removes) %botnicks'?s .+" 100 bMotion_plugin_complex_action_pinch "en"

proc bMotion_plugin_complex_action_pinch { nick host handle channel text } {  
  global botnicks
  if [regexp -nocase "(steals|pinches|theives|removes|takes) ${botnicks}'?s (.+)" $text matches action object] {
    # TODO: check $object and $action (e.g. pinches arse)
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{stolens}"
    bMotionGetSad
    # TODO: switch to using plugin settings for this
    set bMotionCache(lastEvil) $nick
    driftFriendship $nick -1
    return 1
  }
}
