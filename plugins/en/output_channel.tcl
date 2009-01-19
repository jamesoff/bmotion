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

# built-in processing, %channel
# syntax: %channel

proc bMotion_plugin_output_channel { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_channel $channel $line"

	regsub "%channel" $line $channel line

	return $line
}

bMotion_plugin_add_output "channel" bMotion_plugin_output_channel 1 "en" 11
