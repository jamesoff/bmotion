## bMotion plugin: waves
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

bMotion_plugin_add_action_complex "waves" "waves (at|to) %botnicks" 100 bMotion_plugin_complex_action_waves "en"

proc bMotion_plugin_complex_action_waves { nick host handle channel text } {
  bMotionDoAction $channel "" "/waves back"
  bMotionGetUnLonely
  driftFriendship $nick 1
  return 0
}