# vim: fdm=indent fdn=1
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2011
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, %=
# syntax: %={thing1:thing2:thingN:...}
#         Picks one of the things and uses that
#         Kind of like an anonymous abstract

proc bMotion_plugin_output_switch { channel line } {
	bMotion_log "output" "TRACE" "bMotion_plugin_output_switch $channel $line"

	if {[regexp "%=\{(\[^\}\]+)\}" $line matches switch]} {
		bMotion_log "output" "DEBUG" "found switch with text: $switch, and matches $matches, and matches $matches"
		set choices [split $switch ":"]
		if {[llength $choices] == 1} {
			bMotion_log "output" "DEBUG" "only one choice, using that"
			set choice $switch
		} else {
			bMotion_log "output" "DEBUG" "switch choices list is $choices"
			set choice [pickRandom $choices]
			bMotion_log "output" "DEBUG" "switch picked $choice"
		}

		set location [string first $matches $line]
		if {$location == -1} {
			# something's broken
			bMotion_log "output" "ERROR" "bMotion: error parsing $whole_thing in $line, unable to insert $replacement"
			return ""
		}

		set line [string replace $line $location [expr $location + [string length $matches] - 1] $choice]
	}
	return $line
}

bMotion_plugin_add_output "=" bMotion_plugin_output_switch 1 "en" 1
