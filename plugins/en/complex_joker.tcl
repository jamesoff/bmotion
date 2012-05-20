#    - based on an idea from sitting in the pub with JamesOff
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) Andrew Payne 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# register the invoke a joke callback
bMotion_plugin_add_complex "joker" "^(%botnicks:? )?!joke" 100 "bMotion_plugin_complex_invoke_joke" "en"

proc bMotion_plugin_output_JOKE { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_JOKE $channel $line"

	set location [string first "%JOKE" $line]
	if {$location == -1} {
		putlog "bMotion: error parsing $whole_thing in $line, unable to remove JOKE element"
		return ""
	}
	set joke [bMotion_plugin_complex_joke_generate $channel]

	set line [string replace $line $location [expr $location + [string length "%JOKE"] - 1] $joke]

	return $line
}

bMotion_plugin_add_output "JOKE" bMotion_plugin_output_JOKE 1 "en" 5 

proc bMotion_plugin_complex_invoke_joke { nick host handle channel text } {
	# I'll have no part in this if i'm telling a joke already
	set timestamp [bMotion_plugins_settings_get "complex:joker" $channel "" ""]
	if {$timestamp != ""} {
		set now [clock seconds]
		if {[expr $now - $timestamp] < 8} {
			bMotion_putloglev d * "being asked to tell a joke too soon after the last one, ignoring"
			# but we want to stop people trying to flood us
			return 1
		}
	}

	if { ![bMotion_interbot_me_next $channel] } {
		return 0
	}

	bMotion_plugins_settings_set "complex:joker" $channel "" "" [clock seconds]

	bMotionDoAction $channel $nick [bMotion_plugin_complex_joke_generate $channel]
	return 1
}

proc bMotion_plugin_complex_joke_generate { channel } {
	global bMotion_abstract_contents jokeInfo

	# we need the index to coordinate with the reply
	# %n is random noun
	set jokeForms {
		"what's the difference between %n and %n?"
		"what's the difference between %n and %n?"
		"what do you get when you cross %n and %n?"
		"what do you get when you cross %n and %n?"
		"what do you think you could do with %n?"
		"how do you make %n?"
		"did you hear the one about %n?"
		"what's %VAR{colours} and invisible?"
		"what's %VAR{colours} and sticky?"
		"how many %VAR{sillyThings:strip,plural} does it take to change a light bulb?"
		"how many %VAR{sillyThings:strip,plural} does it take to change %VAR{sillyThings}?"
		"what do you do if a blonde throws %VAR{sillyThings} at you?"
		"what do you do if a blonde throws %VAR{sillyThings} at you?"
		"what noise does a %VAR{animals} with no %VAR{bodypart:plural} make?"
		"yo momma so fat, when she %VAR{sillyVerbs:present}, %VAR{sillyThings:strip,plural} %VAR{sillyVerbs}!"
	}

	# %r is relational
	# %n is random noun
	set jokeReplies {
		"%={one's %r and the other's %r:not that much:more than you could possibly imagine!}"
		"one's %n and the other's %n"
		"%r with %r!"
		"%r"
		"become %r"
		"use %r"
		"it was %r"
		"%={no:an invisible} %VAR{sillyThings:strip}"
		"%n"
		"%NUMBER{10} to hold the %VAR{sillyThings:strip} and %NUMBER{15} to %VAR{dVerbs} it"
		"%NUMBER{50}"
		"pull the %VAR{sillyThings:strip} out and throw it back!"
		"%VAR{sillyVerbs}"
		"%VAR{sound2}"
		""
	}

	set index [ rand [ llength $jokeForms ] ]
	set joke [ lindex $jokeForms $index ]

	# have a different random thing for every %n tag
	# this is here because the abstract replaces them all with the same silly thing
	# instead of one for each occurance. That might be expected behaviour, so we'll
	# just do it here instead.
	set things [list]
	while { [string first "%n" $joke] != -1 } {
		set object [bMotion_abstract_get "sillyThings"]
		regsub "%n" $joke $object joke
		lappend things $object
	}
	lappend things ""


	# prepare the answer
	set answer [ lindex $jokeReplies $index ]

	while { [string first "%r" $answer] != -1 } {
		set thing [lindex things 0]
		set object ""
		catch {
			set answers $bMotionFacts(what, $thing)
			if {[llength $answers] > 0} {
				set object [pickRandom $answers]
			}
		} err
		if { $object == "" } {
			set object [bMotion_abstract_get "sillyThings"]
		}
		
		regsub "%r" $answer $object answer
		set things [lreplace $things 0 1]
	}

	while { [string first "%n" $answer] != -1 } {
		set object [bMotion_abstract_get "sillyThings"]
		regsub "%n" $answer $object answer
	}

	# tell the joke
	if {$joke != ""} {
		if {$answer != ""} {
			if {[llength [bMotion_interbot_otherbots $channel]] > 0} {
				set answer "%BOT\[$answer\]"
			}
			set joke "$joke%|%DELAY{8}%|$answer"
		}
	}
	return $joke

}

bMotion_abstract_register "joke_difference" {
	"one's %r and the other's %r"
	"you can't unload a lorry of %rs with a pitchfork!"
}

bMotion_abstract_register "joke_cross" {
	"%r with %r!"
	"%r"
}
