## bMotion plugin: blblbl
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

bMotion_plugin_add_complex "snap" "." 100 bMotion_plugin_complex_snap "en"

proc bMotion_plugin_complex_snap { nick host handle channel text } {
  bMotion_flood_undo $nick
  if {($text == [bMotion_plugins_settings_get "complex:snap" $channel "" "text"]) &&
      ($nick != [bMotion_plugins_settings_get "complex:snap" $channel "" "nick"])} {
        if [rand 3] {
          bMotionDoAction $channel "" "%VAR{snaps}"
          bMotion_plugins_settings_set "complex:snap" $channel "" "text" ""
          bMotion_plugins_settings_set "complex:snap" $channel "" "nick" ""
        }
      }
  bMotion_plugins_settings_set "complex:snap" $channel "" "text" $text
  bMotion_plugins_settings_set "complex:snap" $channel "" "nick" $nick
}

bMotion_abstract_register "snaps"
bMotion_abstract_batchadd "snaps" [list "o snap" "SNAP" "SNAP!"]