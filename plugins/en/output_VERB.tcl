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


# built-in processing, %VERB

proc bMotion_plugin_output_VERB { channel line } {

	set previous_line ""

	while {[regexp -nocase "%VERB\{(.*?)\}" $line matches BOOM]} {
		regsub -nocase "%VERB\{$BOOM\}" $line [bMotionMakeVerb $BOOM] line
		if {$line == $previous_line} {
			putlog "bMotion: ALERT! looping too much in %VERB code with $line (no change since last parse)"
			set line ""
			break
		}
		set previous_line $line
	}

	return $line
}

bMotion_plugin_add_output "VERB" bMotion_plugin_output_VERB 1 "en" 5
