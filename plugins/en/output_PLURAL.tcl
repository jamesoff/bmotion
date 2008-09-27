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


# built-in processing, %PLURAL

proc bMotion_plugin_output_PLURAL { channel line } {

	set previous_line ""
	while {[regexp -nocase "%PLURAL\{(.*?)\}" $line matches BOOM]} {
		# set line [bMotionInsertString $line "%PLURAL\{$BOOM\}" [bMotionMakePlural $BOOM]]
		regsub -nocase "%PLURAL\{$BOOM\}" $line [bMotionMakePlural $BOOM] line
		if {$line == $previous_line} {
			putlog "bMotion: ALERT! looping too much in %PLURAL code with $line (no change since last parse)"
			set line ""
			break
		}
		set previous_line $line
	}
	return $line
}

bMotion_plugin_add_output "PLURAL" bMotion_plugin_output_PLURAL 1 "en" 5
