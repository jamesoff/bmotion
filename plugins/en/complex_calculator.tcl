# bMotion complex plugins
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#                          name   regexp               chance  callback
bMotion_plugin_add_complex "calculator" {what('s| is) (\(*\s*[0-9.]+(\s*[+/*x%-]\s*\(*\s*[0-9.]+\s*\)*)+\s*\)*)} 100 "bMotion_plugin_complex_calculator" "en"

bMotion_plugin_add_complex "calculator2" {what('s| is) the diff(erence)? between (.+ )?\d+,? and (.+ )?\d+} 100 "bMotion_plugin_complex_calculator2" "en"

#################################################################################################################################
# Declare plugin functions

proc bMotion_plugin_complex_calculator { nick host handle channel text } {
	if {[bMotionTalkingToMe $text] || [bMotion_interbot_me_next $channel]} {
		if [regexp -nocase {(\(*\s*[0-9.]+(\s*[+/*x%-]\s*\(*\s*[0-9.]+\s*\)*)+\s*\)*)} $text matches sum] {
			set sum [string map { x * } $sum]
			set sum [string trim $sum]
			set result "failed"
			catch {
				set result [expr $sum]
			}
			if {![string is double $result]} {
				bMotionDoAction $channel $sum "%VAR{calculation_error}" "" 1
				return 1
			}
			bMotionDoAction $channel $sum "$nick: %VAR{calculation_output}" $result 1
			return 1
		}
	} else {
		return 0
	}
}

proc bMotion_plugin_complex_calculator2 { nick host handle channel text } {
	if {[bMotionTalkingToMe $text] || [bMotion_interbot_me_next $channel]} {
		if [regexp {what('s| is) the diff(erence)? between (.+ )?(\d+),? and (.+ )?(\d+)} $text matches 1 2 3 left 4 right] {
			set result [expr abs($right - $left)]
			bMotionDoAction $channel $result "%VAR{calculation_difference}"
			return 1
		}
	} else {
		return 0
	}
}

bMotion_abstract_register "calculation_output" {
	"%% = %2"
	"%% is %2"
	"%% equals %2"
	"%% = %2%|/= autoabacus %NUMBER{9}000"
	"%% = %NUMBER{1000}%|oops, forgot to carry the one %VAR{unsmiles}%|actually, it's %2"
	"%2"
	"%% = %2%|honestly, that was an easy one. couldn't you have worked that out yourself"
	"%% == %2"
	"that's %2"
	"7%|(%2)"
	"honestly, brain the size of a planet and all you can do is ask me to calculate %%?%|it's %2%|point %NUMBER{9}"
	"honestly, brain the size of %VAR{sillyThings} and all you can do is ask me to calculate %%?%|it's %2"
}

bMotion_abstract_register "calculation_error" {
	"%% is%|er%|dunno %VAR{smiles}"
	"/shrug"
	"%% == minus %VAR{sillyThings}{strip}"
	"%% = %VAR{colours}"
	"%% = yo momma"
}

bMotion_abstract_register "calculation_difference" {
	"%%"
}
