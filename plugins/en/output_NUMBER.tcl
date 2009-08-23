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


# built-in processing, %NUMBER
# %NUMBER{x} --> a number between 0 and x
# %NUMBER{x}{y} --> a number between 0 and y padded with 0s to make it y chars

proc bMotion_plugin_output_NUMBER { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_NUMBER $channel $line"

	set padding 0
	if {[regexp "%NUMBER\{(\[0-9\]+)\}(\{(\[0-9\]+)\})?" $line matches numberString paddingOpt padding]} {
		set var [bMotion_get_number [bMotion_rand_nonzero $numberString]]
		if {$padding > 0} {
			set fmt "%0$padding"
			append fmt "u"
			set var [format $fmt $var]
		}
		set line [bMotionInsertString $line "%NUMBER\\{$numberString\\}(\\{\[0-9\]+\\})?" $var]
		set padding 0
	}

	return $line
}

bMotion_plugin_add_output "NUMBER" bMotion_plugin_output_NUMBER 1 "en" 5
