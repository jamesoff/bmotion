## bMotion plugin: kill
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

bMotion_plugin_add_complex "spoon" {^(([^aeiou]+)[aeiuo][a-z]+) ([a-z]+ )?([^aeiou]*([aeiuo][a-z]+))$} 1 bMotion_plugin_complex_spoon "en"

proc bMotion_plugin_complex_spoon { nick host handle channel text } {

  if {[regexp -nocase {^(([^aeiou]+)([aeiuo][a-z]+)) ([a-z]+ )?(([^aeiou]*)([aeiuo][a-z]+))$} $text matches 1 2 3 4 5 6 7]} {
		if {"$6$3 $4$2$7" != $text} {
    	bMotionDoAction $channel "" "$text ... more like $6$3 $4$2$7, am i rite?"
    	return 1
		}
  }
}
