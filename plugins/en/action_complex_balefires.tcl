## bMotion plugin: balefires
#
# $Id$

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "balefires" "^balefires" 100 bMotion_plugin_complex_action_balefires "en"

proc bMotion_plugin_complex_action_balefires { nick host handle channel text } {
	global botnicks
  if [regexp -nocase "^balefires (.+)" $text ming who] {
    global bMotionInfo
    if [regexp -nocase $botnicks $who] {
      bMotionDoAction $channel $nick "%VAR{balefired}"
      bMotionGetUnLonely
      bMotionGetUnHappy
      driftFriendship $nick -1
    } else {
      if {![onchan $who $channel]} { return 0 }
      if {$bMotionInfo(balefire) != 1} { return 0 }
      putserv "PRIVMSG $who :Sorry, you stopped existing a few minutes ago. Please sit down and be quiet until you are woven into the pattern again."
    }
    return 1
  }
}