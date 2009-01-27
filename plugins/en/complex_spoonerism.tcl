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

bMotion_plugin_add_complex "spoon" {^([^%/aeiou. ]+)([aeiuo][a-z]+) ([a-z]+ )?([^aeiou. ]*)([aeiuo][a-z]+)$} 1 bMotion_plugin_complex_spoon "en"

bMotion_plugin_add_complex "spoooooon" {^[b-df-hj-np-tv-xz]+[aeiou]{2}[b-df-hj-np-tv-xz]+[.!?]?$} 40 bMotion_plugin_complex_spoon2 "en"

bMotion_plugin_add_complex "somethingless" {[a-z]+less [a-z]+} 40 bMotion_plugin_complex_spoon3 "en"


proc bMotion_plugin_complex_spoon { nick host handle channel text } {

	if (![bMotion_interbot_me_next $channel]) {
		return 0
	}

	if {[regexp -nocase {^([^%/aeiou. ]+)([aeiuo][a-z]+) ([a-z]+ )?([^aeiou. ]*)([aeiuo][a-z]+)$} $text matches 1 2 3 4 5 6 7]} {
		if {![string equal -nocase "$4$2 $3$1$5" $text]} {
			bMotionDoAction $channel $text "%VAR{spoonerisms}" "$4$2 $3$1$5"
			return 1
		}
	}
}

proc bMotion_plugin_complex_spoon2 { nick host handle channel text } {

	if (![bMotion_interbot_me_next $channel]) {
		return 0
	}

	if [regexp -nocase {([b-df-hj-np-tv-xz]+)(([aeiou])\3)([b-df-hj-np-tv-xz]+[.!?]?)} $text matches 1 2 3 4] {
		bMotionDoAction $channel $text "$1%REPEAT{2:10:$2}$3$4"
		return 1
	}
}


proc bMotion_plugin_complex_spoon3 { nick host handle channel text } {

	if (![bMotion_interbot_me_next $channel]) {
		return 0
	}

	if [regexp -nocase {([a-z]+)less ([a-z]+)\M} $text matches one two] {
		if [regexp -nocase "(unless|useless)" $one] {
			return 0
		}

		if {[string range $two end end] == "s"} {
			append one "s"
			set two [string range $two 0 end-1]
		}
		bMotionDoAction $channel "" "${two}less $one"
		return 1
	}
}


bMotion_abstract_register "spoonerisms"
bMotion_abstract_batchadd "spoonerisms" [list "%% ... more like %2, am i rite?" "%% ... more like %2, am i right?" "%%? More like %2, am I correct?" "/. o O (%2)"]
