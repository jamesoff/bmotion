#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "xmas" "(merry|happy|have a good) (xmas|christmas|chrismas|newyear|new year) %botnicks" 100 bMotion_plugin_complex_xmas "en"

proc bMotion_plugin_complex_xmas { nick host handle channel text } {
  bMotionGetHappy
  bMotionGetUnLonely
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "merry christmas and happy new year %% %VAR{smiles}"
  driftFriendship $nick 3
  return 1
}
