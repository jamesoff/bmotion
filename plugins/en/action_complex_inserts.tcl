## bMotion plugin: inserts

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



bMotion_plugin_add_action_complex "insert" "(parks|puts|places|inserts|shoves|sticks) (his|her|a|the|some) (.+) (in|on|up) %botnicks" 100 bMotion_plugin_complex_action_inserts "en"


proc bMotion_plugin_complex_action_inserts { nick host handle channel text } {
	global botnicks
  #parks/puts

  if [regexp -nocase "(parks|puts|places|inserts|shoves|sticks) (his|her|a|the|some) (.+) (in|on|up) $botnicks" $text ming verb other item] {

    #is it someone we like or are we kinky?

    if {![bMotionLike $nick $host] && ![bMotion_setting_get "kinky"]} {

        bMotionDoAction $channel $nick "%VAR{parkedinsDislike}"
      bMotionGetSad

      bMotionGetUnLonely

      driftFriendship $nick -1

      return 1
    }



    bMotionGetHorny

    bMotionGetHappy

    bMotionGetUnLonely

    bMotionDoAction $channel $nick "%VAR{lovesits}"

    return 1
  }

}