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

bMotion_plugin_add_output "censor" bMotion_plugin_output_censor 0 "en" 90 

proc bMotion_plugin_output_censor { channel line } {
	set replacement_list [split [bMotion_setting_get "censorwords"] " "]

	if {[llength $replacement_list] == 0} {
		return $line
	}

	set replacement [bMotion_setting_get "censorbeep"]
	if {$replacement == ""} {
		set replacement "BEEP"
	}

	set re [join $replacement_list "+|"]
	set re "(${re}+)(ed|ing|er)?"

	putlog $re

	regsub -all -nocase $re $line $replacement line

  return $line
}
