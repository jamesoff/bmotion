## bMotion plugin: smacks
#
# $Id$

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "smacks" "^attacks %botnicks" 100 bMotion_plugin_complex_action_smacks "en"

proc bMotion_plugin_complex_action_smacks { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "(kicks|smacks|twats|injures|beats up|punches|hits|thwaps|slaps|pokes|kills|destroys) ${botnicks}" $text] {
    bMotionGetUnHappy
    bMotionGetUnLonely
    driftFriendship $nick -2
    if [rand 2] {
      frightened $nick $dest
      return 1
    }
    bMotionDoAction $dest $nick "/%VAR{smacks} %% back with %VAR{sillyThings}"
    return 1
  }
}