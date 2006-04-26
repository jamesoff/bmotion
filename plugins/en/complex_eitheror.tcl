## bMotion am not!
#
# $Id: complex_fry.tcl 628 2005-08-19 21:30:28Z notopic $
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

bMotion_plugin_add_complex "eitheror" {%botnicks[;:,] (.+) or (.+)} 100 bMotion_plugin_complex_eitheror "en"

proc bMotion_plugin_complex_eitheror {nick host handle channel text} {
	global botnicks

	#dirty hack to fix work with my trivia script
	if {$nick == "TriviaCow"} {
		return 0
	}

	if [regexp -nocase {([^ ]+) or ([^ ?]+)\?*} $text matches first second] {
		if [rand 2] {
			bMotionDoAction $channel $nick "%VAR{eitherors}" $first
		} else {
			bMotionDoAction $channel $nick "%VAR{eitherors}" $second
		}
		return 1
	}

  return 0
}

bMotion_abstract_register "eitherors"
bMotion_abstract_batchadd "eitherors" [list "%%: %2" "/thinks%|%%: %2" "/ponders%|%%: %2" "/flips a coin%|%%: %2" "%%: %2%|Or you could just use a placebo"]
