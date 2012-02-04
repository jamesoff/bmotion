#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2012
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


bMotion_plugin_add_action_complex "freshens" "^freshens %botnicks" 100 bMotion_plugin_complex_action_freshen "en"

proc bMotion_plugin_complex_action_freshen { nick host handle channel text } {
	global botnicks
	if [regexp -nocase "freshens ${botnicks}('s (.+))?" $text matches 1 2 what] {
		if {$what == ""} {
			bMotionDoAction $channel $nick "%VAR{freshened}"
			driftFriendship $handle 2
			return 1
		}
		bMotionDoAction $channel $nick "%VAR{freshened_thing}" $what
		driftFriendship $handle 2
		return 1
	}
	return 0
}

bMotion_abstract_register "freshened" {
	"%VAR{thanks}"
	"%={%me:mmm...} evaluation: %% fresh!"
}

bMotion_abstract_register "freshened_thing" {
	"%VAR{thanks}"
	"nothing worse than a stale %2"
	"my %2 is now %% fresh %SMILEY{smile}"
}

bMotion_plugin_add_action_complex "fallsout" "^falls out with %botnicks" 100 bMotion_plugin_complex_action_fallsout "en"

proc bMotion_plugin_complex_action_fallsout { nick host handle channel text } {
	if [bMotionIsFriend $nick] {
		bMotionDoAction $channel $nick "%VAR{felloutfriend}"
		driftFriendship $nick -10
		return 1
	}

	bMotionDoAction $channel $nick "%VAR{fellout}"
	return 1
}

bMotion_abstract_register "felloutfriend" {
	"aww %VAR{bigsad} we used to be friends"
	"sad times"
	"didn't like you anyway"
}

bMotion_abstract_register "fellout" {
	"%VAR{fuckoff}%!, never liked you"
	"good"
	"%VAR{PROM}"
}

