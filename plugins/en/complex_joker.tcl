# simsea's Invoke-A-Joke plugin
#    - based on an idea from sitting in the pub with JamesOff
# $Id$
#
###############################################################################
# This is a bMotion plugin
# Copyright (C) Andrew Payne 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# tell a random joke plugin
set jokeInfo ""

# tell a random answer callback
proc bMotionDoJokeAnswer {} {
	global jokeInfo jokeReplies bMotion_abstract_contents bMotionFacts

	# if we're not telling a joke, what are we doing here?
	if { $jokeInfo == "" } { return 0 }
	
	# parse out the first 3 bits of info
	regexp -nocase "(.+)¦(.+)¦(.+):(.+)" $jokeInfo pop nick channel index bits
	
	# coordinate with the joke
	set answer [ lindex $jokeReplies $index ]
	
	# parse relational nouns 
	while { [string first "%r" $answer] != -1 } {
		set ind [string first "¦" $bits]
		if { $ind == -1 } {
			bMotionDoAction $channel $nick "%VAR{lostPlot}"
			return 0
		}
		set thing [string range $bits 0 [ expr $ind - 1 ] ]
		set bits [string range $bits [ expr $ind + 2 ] end ]
		set object ""
		catch {
			set answers $bMotionFacts(what, $thing)
			if {[llength $answers] > 0} {
				set object [pickRandom $answers]
			}
		} err
		if { $object == "" } {
			set object [pickRandom $bMotion_abstract_contents(sillyThings)]
		}
		
		regsub "%r" $answer $object answer
	}

	# parse non-relational
	while { [string first "%n" $answer] != -1 } {
		set object [pickRandom $bMotion_abstract_contents(sillyThings)]
		regsub "%n" $answer $object answer
	}

	# tell the answer
	bMotionDoAction $channel $nick $answer
	
	# reset joke
	set jokeInfo ""

	# log this
	bMotion_putloglev d * "bMotion: (joker) I made a funny"
	return 0 
}

# random joke callback
proc bMotion_plugin_complex_invoke_joke { nick host handle channel text } {
	global bMotion_abstract_contents jokeInfo jokeForms

	# check if we're already telling a joke
	if { $jokeInfo != "" } {
		bMotionDoAction $channel $nick "I'm sorry, but can't you see I'm already telling a joke?!"
		return 0
	}

	# we need the index to coordinate with the reply
	set index [ rand [ llength $jokeForms ] ]
	set joke [ lindex $jokeForms $index ]
	# set the startings of the joke info
	set jokeInfo "$nick¦$channel¦$index:"

	# have a different random thing for every %n tag
	# this is here because the abstract replaces them all with the same silly thing
	# instead of one for each occurance. That might be expected behaviour, so we'll
	# just do it here instead.
	while { [string first "%n" $joke] != -1 } {
		set object [pickRandom $bMotion_abstract_contents(sillyThings)]
		regsub "%n" $joke $object joke
		set jokeInfo "$jokeInfo$object¦"
	}

	# tell the joke
	bMotionDoAction $channel $nick $joke
	
	# pause before telling the answer
	utimer 20 bMotionDoJokeAnswer
	
	# log this
	bMotion_putloglev d * "bMotion: (joker) I'm a tellin' a joke"
	return 1 
}

# register the invoke a joke callback
bMotion_plugin_add_complex "joker" "^!joke" 100 "bMotion_plugin_complex_invoke_joke" "en"

