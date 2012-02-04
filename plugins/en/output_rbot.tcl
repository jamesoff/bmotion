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


proc bMotion_plugin_output_rbot { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_rbot $channel $line"

	if {[regexp "%rbot(\{(\[^\}\]+)\})?" $line matches param condition]} {
		set ruser [bMotionGetRealName [bMotion_choose_random_user $channel 1 $condition] ""]
		if {$condition == ""} {
			set findString "%rbot"
		} else {
			set findString "%rbot$param"
		}
		regsub $findString $line $ruser line
	}

	return $line
}

bMotion_plugin_add_output "rbot" bMotion_plugin_output_rbot 1 "en" 3
