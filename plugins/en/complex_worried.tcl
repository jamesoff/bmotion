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

bMotion_plugin_add_complex "worried" "i'?m worried about (.+)" 80 bMotion_plugin_complex_worried "en"

proc bMotion_plugin_complex_worried { nick host handle channel text } {
  global botnicks
  if [bMotion_interbot_me_next $channel] {
    if [regexp -nocase "i'?m worried about (\[^,.\]+)" $text matches what] {
      bMotionDoAction $channel $what "%VAR{dontworrys}"
      return 1
    }
  }
}

bMotion_abstract_register "dontworrys" {
  "Don't you worry about %%. I'll worry about blank."
}
