## bMotion plugin: thanks
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

bMotion_plugin_add_complex "thanks" "^(thank(s|z|x)|thankyou|thank you|thx|thanx|ta|cheers|merki|merci)" 100 bMotion_plugin_complex_thanks "en"
proc bMotion_plugin_complex_thanks { nick host handle channel text } {
	if [bMotionTalkingToMe $text] {
	  bMotionDoAction $channel $nick "%VAR{welcomes}"
	  bMotionGetHappy
	  driftFriendship $nick 3
	  return 1
  }
}
