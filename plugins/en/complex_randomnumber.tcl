## bMotion am not!
#
# $Id: complex_fry.tcl 662 2006-01-07 23:27:52Z james $
#
# vim: fdm=syntax fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "randomnumber" "%botnicks ((tell|give) me)|(think (of|up)) a (random )?(negative )?number" 100 bMotion_plugin_complex_rndnum "en"

proc bMotion_plugin_complex_rndnum {nick host handle channel text} {
	global botnicks

	if [regexp -nocase "$botnicks ((tell|give) me)|(think (of|up)) a (random )?(negative )?number(.+)" $text matches bn a b c d rnd neg cond] {
		if {$cond == ""} {
			if {$neg != ""} {
				bMotionDoAction $channel $nick "%%: -%NUMBER{10000}"
			} else {
				bMotionDoAction $channel $nick "%%: %NUMBER{10000}"
			}
			return 1
		}
	}
}

