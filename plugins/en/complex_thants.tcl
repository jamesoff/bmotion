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

bMotion_plugin_add_complex "thants" {^(([^%/aeiou. ]+)[aeiuo][a-z]+) (you )?([^aeiou .]*([aeiuo][a-z]+))$} 1 bMotion_plugin_complex_thants "en"

proc bMotion_plugin_complex_thants { nick host handle channel text } {
	if {![bMotion_interbot_me_next $channel]} {
		return 0
	}

  if {[regexp -nocase {^(([^%/aeiou. ]+)[aeiuo][a-z]+) (you )?([^aeiou .]*([aeiuo][a-z]+))$} $text matches 1 2 3 4 5]} {
    bMotionDoAction $channel "" "$1 $3$4... $2$5"
    return 1
  }
}
