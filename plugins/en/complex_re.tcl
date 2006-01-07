## bMotion plugin: welcome back
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

bMotion_plugin_add_complex "wb" "^(re|wb|welcome back) %botnicks" 85 bMotion_plugin_complex_wb "en"

proc bMotion_plugin_complex_wb { nick host handle channel text } {
  bMotionDoAction $channel "" "re"
  driftFriendship $nick 1
  return 1
}
