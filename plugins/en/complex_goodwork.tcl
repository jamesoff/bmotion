## bMotion plugin: good work
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


bMotion_plugin_add_complex "goodwork" "^(well done|good(work|show)),? %botnicks\.?$" 100 bMotion_plugin_complex_goodwork

proc bMotion_plugin_complex_goodwork { nick host handle channel text } {
  bMotionDoAction $channel $nick "%VAR{harhars}"
  bMotionGetHappy
  bMotionGetUnLonely
  driftFriendship $nick 1
  return 1
}