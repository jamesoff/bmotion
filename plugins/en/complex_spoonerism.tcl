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

bMotion_plugin_add_complex "spoon" {^([^%/aeiou. ]+)([aeiuo][a-z]+) ([a-z]+ )?([^aeiou. ]*)([aeiuo][a-z]+)$} 1 bMotion_plugin_complex_spoon "en"

proc bMotion_plugin_complex_spoon { nick host handle channel text } {

	if [bMotion_interbot_me_next $channel] {
		return 0
	}

  if {[regexp -nocase {^([^%/aeiou. ]+)([aeiuo][a-z]+) ([a-z]+ )?([^aeiou. ]*)([aeiuo][a-z]+)$} $text matches 1 2 3 4 5 6 7]} {
		if {![string equal -nocase "$4$2 $3$1$5" $text]} {
    	bMotionDoAction $channel $text "%VAR{spoonerisms}" "$4$2 $3$1$5"
    	return 1
		}
  }
}

bMotion_abstract_register "spoonerisms"
bMotion_abstract_batchadd "spoonerisms" [list "%% ... more like %2, am i rite?" "%% ... more like %2, am i right?" "%%? More like %2, am I correct?" "/. o O (%2)"]
