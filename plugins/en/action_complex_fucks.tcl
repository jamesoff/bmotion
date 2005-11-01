## bMotion plugin: fucks
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

bMotion_plugin_add_action_complex "fuck" "((s(e|3)x(o|0)r(s|z|5))|(fluffles)|fucks|paalt|shags|paalt|fondles|ravages|rapes|spanks|kisses|zoent|snogs) %botnicks" 100 bMotion_plugin_complex_action_fucks "en"
proc bMotion_plugin_complex_action_fucks { nick host handle channel text } {
  global botnicks
	if [regexp -nocase "((s(e|3)x(o|0)r(s|z|5))|(fluffles)|fucks|paalt|shags|paalt|fondles|ravages|rapes|spanks|kisses|zoent|snogs) $botnicks" $text] {
    if {[regexp -nocase "(ass|arse|bottom|anal|rape(s)?|fist)" $text] && ![bMotion_setting_get "kinky"]} {
      driftFriendship $nick -5
      frightened $nick $channel
      return 1
    }    
		if [bMotionLike $nick $host] {
      driftFriendship $nick 4
      bMotionDoAction $channel %% "%VAR{rarrs}"
      bMotionGetHappy
      bMotionGetHappy
      bMotionGetHorny
      bMotionGetUnLonely
    } else {      
			frightened $nick $channel
      driftFriendship $nick -1    
	}
		return 1
	}
}
