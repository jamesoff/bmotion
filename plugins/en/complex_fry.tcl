## bMotion am not!
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

bMotion_plugin_add_complex "fry1" "i'?ve been as (dumb|stupid) as %botnicks" 100 bMotion_plugin_complex_fry1 "en"
bMotion_plugin_add_complex "technically" "technically \[a-z\]+\\M" 60 bMotion_plugin_complex_technically "en"

proc bMotion_plugin_complex_technically { nick host handle channel text } {
	if {![bMotion_interbot_me_next $channel]} {
		return 0
	}

	if [regexp -nocase "technically (not )?(an? )?(\[a-z\]+)\\M" $text matches a b thing] {
		putlog "thing=$thing, a=$a, b=$b"

		#check stoplist
		if [regexp -nocase "(at)" $thing] {
			return 0
		}

		set response "The best kind of $thing"
		if {$a == "not "} {
			set response "%VAR{technically_worst}"
		}
		bMotionDoAction $channel $thing $response
		return 1
	}
}

proc bMotion_plugin_complex_fry1 {nick host handle channel text} {

	bMotionDoAction $channel "" "am not %SMILEY{sad}"

  return 1
}


bMotion_abstract_register "technically_worst" {
	"The best kind of non-%%"
	"The worst kind of %%"
}
