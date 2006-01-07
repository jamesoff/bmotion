# simsea's summoning script
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

# random summoning callback
proc bMotion_plugin_complex_summon { nick host handle channel text } {
	global summon_privmsg_response

	# bMotion_putloglev d * "bMotion: (summon) entering"
	# check to make sure we should bother
	if { ![bMotion_interbot_me_next $channel] } {
		# bMotion_putloglev d * "bMotion: (summon) not me"
		return 2
	}
	# bMotion_putloglev d * "bMotion: (summon) cleared interbot check"

	# !summon name
	if [regexp -nocase "^!summon (.*)" $text blah name] {
		# need to clean off white space
		set name [string trim $name]
		# also need to check for multiple names
		if { [string first " " $name] != -1 } {
			bMotion_putloglev d * "bMotion: (summon) multiple names... skipping"
			# just ignore it?
			return 2
		}	
		# now we can do our main checks
		if { $name != "" && $name != $nick } {
			# summon the best we can
			if { ![onchan $name $channel] } {
				bMotion_putloglev d * "bMotion: (summon) answering for someone not here"
				bMotionDoAction $channel $name "%VAR{summon_channel_response_notthere}"
			} else {
				bMotion_putloglev d * "bMotion: (summon) answering for someone here"
				bMotionDoAction $channel $name "%VAR{summon_channel_response}"
				set msg [pickRandom $summon_privmsg_response]
				# replacements
				regsub "%chan" $msg $channel msg 
				regsub "%%" $msg $nick msg
				# notify
				puthelp "NOTICE $name :$msg"
				puthelp "PRIVMSG $name :$msg"
			}
			return 1
		}
	} 
	bMotion_putloglev d * "bMotion: (summon) $nick doesn't know what they're doing"
	# poke fun at the idiot
	bMotionDoAction $channel $nick "%VAR{summon_channel_idiot}"
	return 1 
}

# register the summon callback
bMotion_plugin_add_complex "summon" "^!summon" 100 "bMotion_plugin_complex_summon" "en"

set summon_channel_response_notthere {
	"yoooo hooooo! %%!"
	"hello there, %%?"
	"how should I know where %% is?"
	"%% isn't here and I'm comfortable... you look for them"
	"i bet you thought that was gonna work and %% was just gonna show up"
	"even if I knew where %% was, why would I help you?"
	"/searches all over the channel for %%"
}

set summon_channel_response {
	"/prods at %% with %noun"
	"through my awesome powers of telepathy, I shall summon %%!!"
	"/uses a smoke signal to get %%'s attention"
	"/stands behind %% poking them in the back till they turn around"
	"yeh... where is %%?"
	"why do you want to talk to %%?"
}

set summon_privmsg_response {
	"FYI: %% was looking for you on %chan"
	"just so you know %% was asking about you on %chan"
	"%% was too lazy to message you from %chan themselves so I had to"
	"life was good until %% started shouting for you on %chan"
	"once upon a time, in a land called %chan, %% was asking about you"
	"Oi! %chan now! %% looking for you!"
}

set summon_channel_idiot {
	"ANNOUNCEMENT: %% is an idiot. That is all."
	"Pay no attention to %%, the village idiot."
	"oOoOooOO very good %%... now who are you looking for?"
	"DANGER%colen there's an idiot behind the wheel!"
	"/offers %% a quick guide in using stuff"
	"%me knows all... except for whatever %% was trying to accomplish"
	"%%: stop bothering me"
	"you know, %%, it's a miracle you made it past childhood"
	"it's not your fault, %%, you must have walked into a door"
}
