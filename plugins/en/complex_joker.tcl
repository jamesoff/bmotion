# tell a random joke plugin
set jokeInfo ""

# parse command strings
proc multipleParseLine { line } {
	global bMotion_abstract_contents
	
	# have a different random thing for every %n tag
	# this is here because the abstract replaces them all with the same silly thing
	# instead of one for each occurance. That might be expected behaviour, so we'll
	# just do it here instead.
	while { [string first "%n" $line] != -1 } {
		set object [pickRandom $bMotion_abstract_contents(sillyThings)]
		regsub "%n" $line $object line
	}

	# return the output
	return $line	
}

# tell a random answer callback
proc bMotionDoJokeAnswer {} {
	global jokeInfo jokeReplies

	# if we're not telling a joke, what are we doing here?
	if { $jokeInfo == "" } { return 0 }
	
	# parse out the first 3 bits of info
	regexp -nocase "(.+)¦(.+)¦(.+)" $jokeInfo pop nick channel index
	
	# coordinate with the joke
	set answer [ lindex $jokeReplies $index ]
	# parse the answer line
	set answer [ multipleParseLine $answer ]

	# tell the answer
	bMotionDoAction $channel "" $answer
	
	# reset joke
	set jokeInfo ""

	# log this
	bMotion_putloglev d * "bMotion: (joker) I made a funny"
	return 0 
}

# random joke callback
proc bMotion_plugin_complex_invoke_joke { nick host handle channel text } {
	global jokeInfo jokeForms

	# check if we're already telling a joke
	if { $jokeInfo != "" } {
		bMotionDoAction $channel $nick "I'm sorry, but can't you see I'm already telling a joke?!"
		return 0
	}

	# we need the index to coordinate with the reply
	set index [ rand [ llength $jokeForms ] ]
	set joke [ lindex $jokeForms $index ]
	# set the startings of the joke info
	set jokeInfo "$nick¦$channel¦$index"

	# parse the joke
	set joke [ multipleParseLine $joke ]

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

