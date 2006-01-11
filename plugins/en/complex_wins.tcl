# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "wins" "^${botnicks}(:?) (wins|exactly|precisely|perfect|nice one|yes)\[!1.\]*$" 100 bMotion_plugin_complex_wins "en"

proc bMotion_plugin_complex_wins { nick host handle channel text } {
   bMotionDoAction $channel $nick "%VAR{wins}"
   bMotionGetHappy
   bMotionGetUnLonely
   driftFriendship $nick 1
   return 1
}

set wins {
  "victory for %me%colen"
  "this victory strengthens the soul of %me!"
  "%VAR{harhars}"
  "%VAR{thanks}"
  "wh%REPEAT{2:6:e}! do I get %VAR{sillyThings} now?"
}

bMotion_abstract_register "wins"
bMotion_abstract_batchadd "wins" $wins
unset $wins

