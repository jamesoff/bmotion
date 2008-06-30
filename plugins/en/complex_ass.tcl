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

bMotion_plugin_add_complex "ass" {([a-z]+)[- ]ass ([a-z]+)} 85 bMotion_plugin_complex_ass "en"

proc bMotion_plugin_complex_ass { nick host handle channel text } {

	if {![bMotion_interbot_me_next $channel]} {
		return 0
	}

	if [regexp -nocase {([a-z]+)[- ]ass ([a-z]+)} $text matches 1 2] {
		bMotionDoAction $channel "" "$1 ass-$2"
	}
}
