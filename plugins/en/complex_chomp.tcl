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

bMotion_plugin_add_complex "chomp" "^%botnicks,?:? ?(please )?chomp" 100 bMotion_plugin_complex_chomp "en"

proc bMotion_plugin_complex_chomp { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^$botnicks,?:? ?(please )?chomp (.+)" $text matches ming ming2 who] {
    global bMotionInfo
    if {![regexp -nocase $botnicks $who]} {
      bMotionDoAction $channel $nick "/bites $who's %VAR{bodypart}"
      bMotionGetUnLonely
    } else {
      bMotionDoAction $channel "" "/looks at suspiciously at $nick"
      bMotionDoAction $channel "" "Do I look like Ouroboros?!"
      driftFriendship $nick -1
    }
    return 1
  }
}
