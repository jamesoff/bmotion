## bMotion plugin: makes
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

bMotion_plugin_add_action_complex "makes" "^makes %botnicks" 100 bMotion_plugin_complex_action_makes "en"

proc bMotion_plugin_complex_action_makes { nick host handle channel text } {
  if [regexp -nocase "makes $botnicks (.+)" $text ming ming2 details] {
    global bMotionInfo

    if {![bMotionLike $nick $host]} {
      frightened $nick $dest
      return 1
    }

    if [regexp -nocase "(come|cum)" $details] {
      if {![bMotionLike $nick $host]} {
        frightened $nick $dest
        driftFriendship $nick -2
        return 1
      }

      if {$bMotionInfo(gender) == "male"} {
        bMotionDoAction $dest $nick "/cums over %%"
        bMotionDoAction $dest $nick "ahhh... thanks, I needed that"
        bMotionGetHappy
        bMotionGetHappy
        bMotionGetUnHorny
        driftFriendship $nick 2
        return 1
      }
      # female
      bMotionDoAction $dest $nick "%VAR{lovesits} :D"
      bMotionGetHappy
      bMotionGetHappy
      bMotionGetHorny
      driftFriendship $nick 2
      return 1
    }
  }
}