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


# built-in processing, %!
# syntax: %!{<N>}
#         N is a percent chance of stopping output

proc bMotion_plugin_output_break { channel line } {
	bMotion_log "output" "TRACE" "bMotion_plugin_output_break $channel $line"

	if {[regexp "(.*)%!(\{(\[0-9\]+)\})?(.+)" $line matches newline option chance rest]} {
		if {$chance == ""} {
			set chance 50
		}
		bMotion_log "output" "DEBUG" "found %BREAK with chance of $chance"

		set n [rand 100]
		bMotion_log "output" "DEBUG" "%BREAK n is $n"
		if {$n < $chance} {
			bMotion_log "output" "DEBUG" "nuking output from %BREAK marker in $line"
			set line $newline
			bMotion_log "output" "DEBUG" "post-nuke output is $newline"
		} else {
			bMotion_log "output" "DEBUG" "keeping entire line"
			set line "${newline}${rest}"
		}
	}
	return $line
}

bMotion_plugin_add_output "!" bMotion_plugin_output_break 1 "en" 1
