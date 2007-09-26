# simsea's Invoke-A-Joke plugin
#    - based on an idea from sitting in the pub with JamesOff
# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) Andrew Payne 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# register the invoke a joke callback
bMotion_plugin_add_complex "joker" "^(%botnicks:? )?!joke" 100 "bMotion_plugin_complex_invoke_joke" "en"

# random joke callback
proc bMotion_plugin_complex_invoke_joke { nick host handle channel text } {
	global bMotion_abstract_contents jokeInfo 

	# I'll have no part in this if i'm telling a joke already
	set timestamp [bMotion_plugins_settings_get "complex:joker" $channel "" ""]
	if {$timestamp != ""} {
		set now [clock seconds]
		if {[expr $now - $timestamp] < 10} {
			bMotion_putloglev d * "being asked to tell a joke too soon after the last one, ignoring"
			# but we want to stop people trying to flood us
			return 1
		}
	}

	if { ![bMotion_interbot_me_next $channel] } {
		return 0
	}

	bMotion_plugins_settings_set "complex:joker" $channel "" "" [clock seconds]

	# we need the index to coordinate with the reply
	# %n is random noun
	set jokeForms {
		"what's the difference between %n and %n?"
		"what do you get when you cross %n and %n?"
		"what do you think you could do with %n?"
		"how do you make %n?"
		"did you hear the one about %n?"
		"what's %VAR{colours} and invisible?"
		"what's %VAR{colours} and sticky?"
	}

	# %r is relational
	# %n is random noun
	set jokeReplies {
		"one's %r and the other's %r"
		"%r with %r!"
		"become %r"
		"use %r"
		"it was %r"
		"no %PLURAL{%VAR{sillyThings}{strip}}"
		"%n"
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
	bMotionDoAction $channel $nick $joke
	bMotionDoAction $channel $nick "%DELAY{10}%|$answer"

	return 1 
}


