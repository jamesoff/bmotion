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

bMotion_plugin_add_output "diddlydots" bMotion_plugin_output_diddlydots 1 "en"

proc bMotion_plugin_output_diddlydots { channel line } {
	if [regexp "^/" $line] { return $line }
	set words [split $line " "]

	set done 0
	set newline ""
	
	foreach word $words {
		bMotion_putloglev 4 * "diddlydots: considering word $word"
		if {$done < 3} {
			if {[string length $word] > 4} {
				bMotion_putloglev 4 * "diddlydots: long enough"
				if [regexp -nocase {^[a-z]+$} $word] {
					if {![regexp -nocase "(which|about|these|those|their|there)" $word]} {
						if {[rand 100] > 97} {
							bMotion_putloglev 4 * "adding quotes"
							set word "\"$word\""
							incr done
						}
					}
				}
			}
		}
		append newline "$word "
	}
	set line [string trim $newline]

  return $line
}
