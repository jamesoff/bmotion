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

# %ruser
# %ruser{friend}
# %ruser{friend:owner}
# %ruser{:owner}

proc bMotion_plugin_output_ruser { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_ruser $channel $line"

	if [regexp "%ruser(\{(\[a-z\]*)?(:(\[a-z,\]+))?\})?" $line matches allopts filter optstring options] {
		bMotion_putloglev 1 * "found %ruser with filter=$filter and options=$options"

		set ruser [bMotionGetRealName [bMotion_choose_random_user $channel 0 $filter] ""]
		
		set options_list [split $options ","]
		foreach option $options_list {
			bMotion_putloglev 1 * "working on option $option"
			switch $option {
				"owner" {
					set ruser [bMotionMakePossessive $ruser]
				}
				"caps" {
					set ruser [string toupper $ruser]
				}
				default {
					putlog "bMotion: unexpected option $option in $matches"
				}
			}
		}
		regsub $matches $line $ruser line
	}

	return $line
}

bMotion_plugin_add_output "ruser" bMotion_plugin_output_ruser 1 "en" 3
