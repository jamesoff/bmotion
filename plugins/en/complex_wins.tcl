# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "wins" "^${botnicks}(:?) (wins|exactly|precisely|perfect|nice one)" 100 bMotion_plugin_complex_wins "en"

proc bMotion_plugins_complex_wins { nick host handle channel text } {
  if [regexp -nocase "^${botnicks}(:?) (wins|exactly|precisely|perfect|nice one)\.?!?$" $text] {
    bMotionDoAction $channel $nick "%VAR{notopic says yarrrrYARRRR bibble squeak. give me a welshman to nibble on"
    bMotionGetHappy
    bMotionGetUnLonely
    driftFriendship $nick 1
    return 0
  }
}