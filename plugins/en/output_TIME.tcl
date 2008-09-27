#
#
# vim: fdm=indent fdn=1
#
 
###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, %TIME

proc bMotion_plugin_output_TIME { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_TIME $channel $line"

	set lastline ""

	while {[regexp "%TIME\{(\[a-zA-Z0-9 -\]+)\}" $line matches timeString]} {
		bMotion_putloglev 2 * "found timestring $timeString"
		set origtime $timeString
		regsub -nocase {^-([0-9]) minutes?$} $timeString "\\1 minutes ago" timeString
		set var [clock scan $timeString]
		set var [clock format $var -format "%I:%M %p"]
		bMotion_putloglev 2 * "using time $var"
		set line [bMotionInsertString $line "%TIME\\{$origtime\\}" $var]

		if {$lastline == $line} {
			# nothing changed
			set line ""
			break
		}
		set lastline $line
	}

	return $line
}

bMotion_plugin_add_output "TIME" bMotion_plugin_output_TIME 1 "en" 5
