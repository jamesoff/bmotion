# vim: fdm=indent fdn=1
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, %REPEAT

proc bMotion_plugin_output_REPEAT { channel line } {
	if {[regexp -nocase "%REPEAT\{(.+?)\}" $line matches BOOM]} {
		set replacement [bMotionMakeRepeat $BOOM]
		regsub -nocase "%REPEAT\\{$BOOM\\}" $line $replacement line
	}
	return $line
}

bMotion_plugin_add_output "REPEAT" bMotion_plugin_output_REPEAT 1 "en" 5
