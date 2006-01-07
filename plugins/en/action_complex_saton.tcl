## bMotion plugin: sits
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

bMotion_plugin_add_action_complex "sits" "^sits on %botnicks" 100 bMotion_plugin_complex_action_sits "en"

proc bMotion_plugin_complex_action_sits { nick host handle channel text } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{satOns}"
  bMotionGetSad
  bMotionGetUnLonely
  driftFriendship $nick -1
  return 1
}
