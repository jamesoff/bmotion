## bMotion output plugin: diddlydots
#
# $Id: output_english.tcl 669 2006-03-01 22:35:22Z james $
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_output "diddlydots" bMotion_plugin_output_diddlydots 1 "en"

proc bMotion_plugin_output_diddlydots { channel line } {
	set words [split $line " "]

	set done 0
	set newline ""
	
	foreach word $words {
		if {$done == 0} {
			if {[string length $word] > 6} {
				if [regexp -nocase {[a-z]} $word] {
					if {[rand 100] > 95} {
						set word "\"$word\""
						set done 1
					}
				}
			}
		}
		append newline "$word "
	}
	set line [string trim $newline]

  return $line
}
