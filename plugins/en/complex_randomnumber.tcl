## bMotion am not!
#
#
# vim: fdm=syntax fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "randomnumber" "%botnicks,?:? (tell|give) me a (random )?(negative )?number" 100 bMotion_plugin_complex_rndnum "en"
bMotion_plugin_add_complex "randomnumber2" "%botnicks,?:? (make|think) (of|up) a (random )?(negative )?number" 100 bMotion_plugin_complex_rndnum "en"

proc bMotion_plugin_complex_rndnum {nick host handle channel text} {
	#TODO: support conditions like "between 10 and 100" or "lower than 10"
	if [regexp -nocase "a (random )?(negative )?number" $text matches rnd neg] {
		if {$neg != ""} {
			bMotionDoAction $channel $nick "%%: -%NUMBER{10000}"
		} else {
			bMotionDoAction $channel $nick "%%: %NUMBER{10000}"
		}
		return 1
	}
}

