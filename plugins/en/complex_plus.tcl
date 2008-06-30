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

bMotion_plugin_add_complex "plus" {^[a-z]+ plus$} 75 bMotion_plugin_complex_plus "en"

proc bMotion_plugin_complex_plus { nick host handle channel text } {
	if [regexp -nocase {^([a-z]+) plus$} $text matches item] {
		bMotionDoAction $channel $item "like regular %% but with a cartridge slot"
		return 1
	}
}
