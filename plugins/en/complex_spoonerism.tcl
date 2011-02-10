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
	global bMotionInfo

	if (![bMotion_interbot_me_next $channel]) {
		return 0
	}

	if {[regexp -nocase {^([^%/aeiou. ]+)([aeiuo][a-z]+) ([a-z]+ )?([^aeiou. ]*)([aeiuo][a-z]+)$} $text matches 1 2 3 4 5 6 7]} {
		if {![string equal -nocase "$4$2 $3$1$5" $text]} {
			if [rand 1] {
				bMotionDoAction $channel $text "%VAR{spoonerisms}" "$4$2 $3$1$5"
			} else {

				# smash heteronormativity!
				if [regexp -nocase "straight" $bMotionInfo(orientation)] {
					bMotionDoAction $channel "$1$2" "%VAR{xhery}" "$4$5"
				} else if [regexp -nocase "(bi|queer)" $bMotionInfo(orientation)] {
					bMotionDoAction $channel "$1$2" "%VAR{xhery_bi}" "$4$5"
				} else if [regexp -nocase "(gay|lesbian|homo)" $bMotionInfo(orientation)] {
					bMotionDoAction $channel "$1$2" "%VAR{xhery_gay}" "$4$5"
				} else {
					# wait, what? panic! default!
					bMotionDoAction $channel "$1$2" "%VAR{xhery}" "$4$5"
					bMotion_putloglev 1 * "bMotion: failed to find sexuality pigeonhole (if you know what i mean)"
				}
			}
			return 1
		}
	}
}

proc bMotion_plugin_complex_spoon2 { nick host handle channel text } {
	if (![bMotion_interbot_me_next $channel]) {
		return 0
	}

	if [bMotion_sufficient_gap 300 "complex:spoonerism" $channel] {
		if [regexp -nocase {([b-df-hj-np-tv-xz]+)(([aeiou])\3)([b-df-hj-np-tv-xz]+[.!?]?)} $text matches 1 2 3 4] {
			if {$matches == "cool"} {
				return 0
			}
			bMotionDoAction $channel $text "$1%REPEAT{2:10:$2}$3$4"
			return 1
		}
	}
	return 0
}


proc bMotion_plugin_complex_spoon3 { nick host handle channel text } {
	if (![bMotion_interbot_me_next $channel]) {
		return 0
	}

	if [bMotion_sufficient_gap 300 "complex:spoonerism" $channel] {
		if [regexp -nocase {([a-z]+)less ([a-z]+)\M} $text matches one two] {
			if [regexp -nocase {^(un|use|b|regard)$} $one] {
				return 0
			}

			if [regexp -nocase {^(and|one|of|n)$} $two] {
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
	return 0
}


bMotion_abstract_register "spoonerisms"
bMotion_abstract_batchadd "spoonerisms" [list "%% ... more like %2, am i rite?" "%% ... more like %2, am i right?" "%%? More like %2, am I correct?" "/. o O (%2)"]

bMotion_abstract_register "xhery_male" [list "I'd %% her %2"]
bMotion_abstract_register "xhery_female" [list "I'd %% his %2"]
bMotion_abstract_register "xhery_bi" [list "%VAR{xhery_male}" "%VAR{xhery_female}"]
bMotion_abstract_register "xhery_gay" [list "I'd %% %hisher %2"]

# We need this blank one for the two above to work
bMotion_abstract_register "xhery"
