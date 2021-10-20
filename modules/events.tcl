# bMotion - Event handling
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2008
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

### bMotionDoEventResponse
proc bMotionDoEventResponse { type nick host handle channel text } {
#check our global toggle
	global bMotionGlobal bMotionInfo bMotionDebug
	if {$bMotionGlobal == 0} {
		return 0
	}

	if [matchattr $handle J] {
		return 0
	}

	set channel [string tolower $channel]

	if {[lsearch $bMotionDebug $channel] > -1} {
		set debug 1
	} else {
		set debug 0
	}

	#ignore other bots
	if {[matchattr $handle b] && (![matchattr $handle I])} {
		set bMotionCache($channel,last) 0
		return 0
	}

	bMotion_putloglev 4 * "entering bMotionDoEventResponse: $type $nick $host $handle $channel $text"
	if { ![regexp -nocase "nick|join|quit|part|split" $type] } {
		return 0
	}

	global bMotionInfo
	set response [bMotion_plugin_find_irc_event $text $type $bMotionInfo(language) $debug]
	if {[llength $response] > 0} {
		foreach callback $response {
			if {!$debug} {
				bMotion_putloglev 2 * "adding flood for callback $callback"
				bMotion_flood_add $nick $callback $text
				if [bMotion_flood_check $nick] { return 0 }
			}

			bMotion_putloglev 1 * "bMotion: matched irc event plugin, running callback $callback"
			set result [$callback $nick $host $handle $channel $text ]
			bMotion_putloglev 2 * "returned from callback $callback"
			if {$result == 1} {
				bMotion_putloglev 2 * "bMotion: $callback returned 1, breaking out..."
				break
			}
			return 1
		}
		return 0
	}
	return 0
}

### bMotion_event_onjoin
proc bMotion_event_onjoin {nick host handle channel} {
	#ignore me
	if [isbotnick $nick] {
		return 0
	}

	#ignore the J flag users
	if [matchattr $handle J] {
		return 0
	}

	#ignore bots without the I flag
	if [matchattr $handle b-I] {
		return 0
	}

	if {![channel get $channel bmotion]} {
		return 0
	}

	set result [bMotionDoEventResponse "join" $nick $host $handle $channel ""]
}

### bMotion_event_onpart
proc bMotion_event_onpart {nick host handle channel {msg ""}} {
#check our global toggle
	global bMotionGlobal
	if {$bMotionGlobal == 0} {
		return 0
	}

	# channel is missing when the bot itself is parting, so ignore itself
	if [isbotnick $nick] {
		return 0
	}

	if {![channel get $channel bmotion]} {
		return 0
	}

	regsub -all {(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])} $reason "" reason

	bMotion_putloglev 3 * "entering bmotion_event_onpart: $nick $host $handle $channel $msg"

	bMotion_plugins_settings_set "system" "lastleft" $channel "" $nick

	#TODO: Fix this? Passing a cleaned nick around can break things
	set nick [bMotion_cleanNick $nick $handle]

	set result [bMotionDoEventResponse "part" $nick $host $handle $channel $msg]
}

### bMotion_event_onquit
proc bMotion_event_onquit {nick host handle channel reason} {
	global bMotionSettings bMotionInfo

	#check our global toggle
	global bMotionGlobal
	if {$bMotionGlobal == 0} {
		return 0
	}

	# channel is missing when the bot itself is quiting, so ignore itself
	if [isbotnick $nick] {
		return 0
	}

	if {![channel get $channel bmotion]} {
		return 0
	}

	regsub -all {(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])} $reason "" reason

	set nick [bMotion_cleanNick $nick $handle]

	bMotion_plugins_settings_set "system" "lastleft" $channel "" $nick

	#check if that person was in the brig
	global bMotionChannels
	foreach chan $bMotionChannels {
		bMotion_putloglev 1 * "Checking $chan for $nick in the brig"
		if {[bMotion_plugins_settings_get "complex:startrek" "brig" $chan ""] == $nick} {
			bMotion_plugins_settings_set "complex:startrek" "brig" $chan "" ""
			bMotionDoAction $chan "" "Curses! They escaped from the brig."
		}
	}
	return [bMotionDoEventResponse "quit" $nick $host $handle $channel $reason ]
}

### bMotion_event_main
proc bMotion_event_main {nick host handle channel text} {
#check our global toggle
	global bMotionGlobal bMotionPluginHistory
	if {$bMotionGlobal == 0} {
		return 0
	}

	## Global definitions ##
	global botnick
	global bMotionLastEvent bMotionSettings botnicks bMotionCache bMotionInfo
	global bMotionThisText bMotionOriginalInput bMotionOriginalNick

	if [matchattr $handle J] {
		return 0
	}

	set bMotionOriginalNick $nick

	set channel [string tolower $channel]

	#ignore other bots
	if {[matchattr $handle b] && (![matchattr $handle I])} {
		set bMotionCache($channel,last) 0
		return 0
	}

	#make sure we're allowed to talk in here
	if {![channel get $channel bmotion]} {
		return 0
	}

	# filter out emoji and other unicode stuff
	# seems to be the cause of a crash: https://github.com/jamesoff/bmotion/issues/43
	# doing this here before $text is used at all to protect eggdrop as much as possible
	regsub -all {(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])} $text "" text

	#don't trigger on !seen etc
	if [regexp -nocase "^!(last)?seen" $text] {
		return 0
	}

	#no bMotion plugin triggers on /^,/ so we can filter them out too
	if [string match ",*" $text] {
		return 0
	}

	bMotion_putloglev 4 * "bMotion: entering bMotion_event_main with nick: $nick host: $host handle: $handle chan: $channel text: $text"

	bMotion_queue_dupecheck $text $channel

	set bMotionOriginalInput $text

	#filter bold, etc codes out
	regsub -all "\002" $text "" text
	regsub -all "\022" $text "" text
	regsub -all "\037" $text "" text
	regsub -all "\017" $text "" text

	# thanks, anonymous ticket poster (ticket #125)
	regsub -all "\003\[0-9\]{0,2}(,\[0-9\]{1,2})?" $text "" text

	#try stripcodes (eggdrop 1.6.17+)
	catch {
		set text [stripcodes bcruag $text]
	}

	bMotion_check_botnicks

	#does this look like a paste?
	if [regexp -nocase {^[([]?[0-9]{2}[-:.][0-9]{2}. ?[[<(]?[%@+]?[a-z0-9` ]+[@+%]?. \w+} $text] {
		return 0
	}

	## Update the channel idle tracker
	set bMotionLastEvent($channel) [clock seconds]

	#don't let people break us
	if {![matchattr $handle n]} {
		if [regexp -nocase "%(pronoun|me|noun|colen|percent|VAR|\\|)" $text] {
			regsub -all "%" $text "%percent" text
		}
	}
	regsub -all "\</" $text "%slash" text

	#If this isn't just a smiley of some kind, trim smilies
	if {[string length $text] >= ([string length $botnick] + 4)} {
		regsub -all -nocase {[;:=]-?[()d<>/sp9x]} $text "" text
		regsub -all {([\-^])_*[\-^];*} $text "" text
		regsub -all {\\o/} $text "" text
	}

	#Trim stuff
	set text [string trim $text]

	## Dump double+ spaces
	regsub -all "  +" $text " " text

	## Update the last-talked flag for the join system
	bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 0

	set bMotionThisText $text

	global bMotionDebug
	if {[lsearch $bMotionDebug $channel] > -1} {
		set debug 1
	} else {
		set debug 0
	}

	#if we spoke last, add "$botnick: " if it's not in the line
	if {![regexp -nocase $botnicks $text] && ([bMotion_did_i_speak_last $channel] || ([bMotion_setting_get "bitlbee"] == "1"))} {
		if [regexp {^[^:]+:.+} $text] {
		#since our nick isn't in the line and they're addressing someone, drop this line
			return 0
		}
		set text "${botnick}: $text"
	}

	if {[bMotion_setting_get "bitlbee"] == "1"} {
		bMotion_putloglev d * "bitlbee incoming from $nick: $text"
	}

	#check for someone breaking the loop of lastSpoke
	if {[regexp -nocase "(i'm not talking to|not) you" $text] && [bMotion_did_i_speak_last $channel]} {
		bMotionDoAction $channel $nick "oh"
		set bMotionCache($channel,last) 0
		return 0
	}
	set bMotionCache($channel,last) 0

	#Run the simple plugins
	set response [bMotion_plugin_find_simple $text $bMotionInfo(language) $debug]
	if {$response != ""} {
		if {!$debug} {
			bMotion_flood_add $nick "" $text
			if [bMotion_flood_check $nick] { return 0 }
			if [bMotion_flood_check $channel] { return 0 }
			bMotion_flood_add $channel "" $text
		}
		set nick [bMotionGetRealName $nick $host]
		bMotionDoAction $channel $nick [pickRandom $response]
		return 0
	}

	#Run the complex plugins
	set response [bMotion_plugin_find_complex $text $bMotionInfo(language) $debug]
	if {[llength $response] > 0} {
	#set nick [bMotionGetRealName $nick $host]
		if {!$debug && [bMotion_flood_check $channel]} { return 0 }
		bMotion_putloglev 1 * "going to run plugins: $response"
		foreach callback $response {
			if (!$debug) {
				bMotion_putloglev 1 * "bMotion: doing flood for $callback..."
				if [bMotion_flood_check $nick] { return 0 }
			}

			bMotion_putloglev 1 * "bMotion: `- running callback $callback"
			set result 0
			set result [$callback $nick $host $handle $channel $text]
			bMotion_putloglev 2 * "returned from $callback"
			set bMotionCache(lastPlugin) $callback
			bMotion_plugin_history_add $channel "complex" $callback

			#plugins should return 1 if they trigger, and 2 if they trigger without output
			# (i.e. return 2 to not increment flood)
			# they should return 0 if they don't trigger

			if {$result > 0} {
				if {!$debug && ($result == 1)} {
					bMotion_putloglev 1 * "adding flood counters"
					bMotion_flood_add $nick $callback $text
					bMotion_flood_add $channel $callback $text
				}
				bMotion_putloglev 2 * "bMotion:		 `-$callback returned $result, breaking out..."
				break
			}
		}
	}

	#Check for all caps
	regsub -all {[^A-Za-z]} $text "" textChars
	regsub -all {[a-z]} $textChars "" textLowerChars
	if {(([string length $textChars] > 4) && ([expr [string length $textLowerChars] / [string length $textChars]] > 0.9)) ||
		 [regexp ".+!{4,}" $text]} {
		global blownAways
		if {[rand 60] >= 55} {
			bMotionDoAction $channel $nick "%VAR{blownAways}"
			return 0
		}
	}

	#Reload config files
	#TODO: move this into a plugin?
	if [regexp -nocase "${botnicks},?:? re(hash|load)( your config files?)?" $text] {
	#putlog "bMotion: $nick asked me to rehash in $channel"
		global bMotion_testing bMotionRoot

		if [matchattr $handle m] {
		#check we're not going to die
		catch {
		bMotion_putloglev d * "bMotion: Testing new code..."
		set bMotion_testing 1
		source "$bMotionRoot/bMotion.tcl"
		} msg

		if {$msg != ""} {
			putlog "bMotion: FATAL: Cannot rehash due to error: $msg"
			putserv "NOTICE $nick :FATAL: Cannot rehash: $msg"
			putchan $channel "A tremendous error occurred!"
			return 0
		} else {
			bMotion_putloglev d * "bMotion: New code ok, rehashing..."
			bMotion_plugins_settings_set "system" "rehash" "" "" $channel
			set bMotion_testing 0
			if {[matchattr $handle m]} {
				putchan $channel [bMotion_abstract_get "rehashes"]
				rehash
				return 0
			}
		}
		} else {
		#don't respond here because there's no flood protection
			return 0
		}
	}

	#tell the names we have
	#TODO: move this into a plugin?
	if [regexp -nocase "${botnicks}:?,? (say my names?|what'?s my name)" $text] {
		if {($handle == "*") || ($handle == "")}	{
		#no handle = no saving IRL
			set lastnick [bMotion_plugins_settings_get "events" "last_irl_fail" $channel ""]
			if {$lastnick == $nick} {
				bMotion_putloglev d * "Ignoring 'say my names' from $nick because they've asked twice in a row"
				return 0
			}
			bMotion_plugins_settings_set "events" "last_irl_fail" $channel "" $nick
			bMotionDoAction $channel $nick "%%: Sorry, you aren't in my userfile so I can't store an IRL name for you."
			return 0
		}

		set realnames [getuser $handle XTRA irl]
		if {$realnames == ""} {
			bMotionDoAction $channel $nick "Ah, you must be %%. (You have not set any IRL names.)" "" 1
		} else {
			bMotionDoAction $channel $nick "Your IRL name(s) are:\002 %2 \002" $realnames 1
		}
		puthelp "NOTICE $nick :To update your IRL names, do \002/msg $botnick IRL name1 name2 name3 ...\002"
		return 0
	}

	#shut up
	#TODO: move this into a plugin?
	if [regexp -nocase "^${botnicks}:?,? (silence|shut up|be quiet|go away)" $text] {
		driftFriendship $nick -10
		bMotionSilence $nick $host $channel
		return 0
	}

	if [regexp -nocase "(silence|shut up|be quiet|go away),?;? ${botnicks}" $text] {
		driftFriendship $nick -10
		bMotionSilence $nick $host $channel
		return 0
	}

	#catch actions in stars
	#This is the clever bit. If the text is "*blah blah blah*" reinject it into bMotion as an action ##
	if [regexp {^\*(.+)\*$} $text blah action] {
		bMotion_putloglev 1 * "Unhandled *$action* by $nick in $channel... redirecting to action handler"
		bMotion_event_action $nick $host $handle $channel "" $action
		return 0
	}
}

### bMotion_event_action
proc bMotion_event_action {nick host handle dest keyword text} {

#check our global toggle
	global bMotionGlobal
	if {$bMotionGlobal == 0} {
		return 0
	}

	global botnick rarrs smiles unsmiles botnicks bMotionCache bMotionSettings bMotionInfo
	set dest [channame2dname $dest]
	set channel $dest

	if [matchattr $handle J] {
		return 0
	}

	#ignore other bots
	if {[matchattr $handle b]} {
		return 0
	}

	if {![channel get $channel bmotion]} {
		return 0
	}

	regsub -all {(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])} $text "" text

	bMotion_putloglev 4 * "bMotion: entering bMotion_event_action with $nick $host $handle $dest $keyword $text"

	set nick [bMotion_cleanNick $nick $handle]
	set channel [string tolower $channel]

	#Trim
	set text [string trim $text]

	## Dump double+ spaces ##
	regsub -all "  +" $text " " text

	#ignore lines with <nobotnick> tags
	if [regexp -nocase "\</?no$botnicks\>" $text] {return 0}
	if [regexp -nocase "\<no$botnicks\>" $text] {return 0}

	bMotion_check_botnicks

	global bMotionDebug
	if {[lsearch $bMotionDebug $channel] > -1} {
		set debug 1
	} else {
		set debug 0
	}

	#Run the simple plugins
	set response [bMotion_plugin_find_action_simple $text $bMotionInfo(language) $debug]
	if {$response != ""} {
		if (!$debug) {
			bMotion_flood_add $nick "" $text
			if [bMotion_flood_check $nick] { return 0 }
			if [bMotion_flood_check $channel] { return - }
			bMotion_flood_add $channel "" $text
		}
		bMotion_putloglev 1 * "bMotion: matched simple action plugin, outputting $response..."
		set nick [bMotionGetRealName $nick $host]
		bMotionDoAction $channel $nick [pickRandom $response]
		return 0
	}

	#Run the complex plugins
	set response [bMotion_plugin_find_action_complex $text $bMotionInfo(language) $debug]
	if {[llength $response] > 0} {
	#set nick [bMotionGetRealName $nick $host]
		if {!$debug && [bMotion_flood_check $channel]} { return 0 }
		bMotion_putloglev 1 * "going to run action plugins: $response"
		foreach callback $response {
			if (!$debug) {
				bMotion_putloglev 1 * "bMotion: doing flood for $callback..."
				if [bMotion_flood_check $nick] { return 0 }
			}
			bMotion_putloglev 1 * "bMotion: matched complex action plugin, running callback $callback"
			set result 0
			set result [$callback $nick $host $handle $channel $text]
			if {$result > 0} {
				if {(!$debug) && ($result == 1)} {
					bMotion_flood_add $nick $callback $text
					bMotion_flood_add $channel $callback $text
				}
				bMotion_putloglev 2 * "bMotion:		 `-$callback returned $result, breaking out..."
				break
			}
		}
		return 0
	}
}

### bMotion_event_mode
proc bMotion_event_mode {nick host handle channel mode victim} {
#check our global toggle
	global bMotionGlobal
	if {$bMotionGlobal == 0} {
		return 0
	}

	if {![channel get $channel bmotion]} {
		return 0
	}

	bMotion_putloglev 4 * "bMotion: entering bMotion_event_mode with $nick $host $handle $channel $mode $victim"

	global botnick
	if {$victim != $botnick} {return 0}

	if {$mode == "+o"} {
		if {$nick == ""} {
			return 0
		}

		#check to see if i was opped before
		if [wasop $botnick $channel] { return 0 }

		set deoptime [bMotion_plugins_settings_get "system" "deoptime" $channel ""]
		set diff 901
		if {$deoptime != ""} {
			set diff [expr [clock seconds] - $deoptime]
		}
		if {$diff > 900} {
			if [bMotion_interbot_is_bmotion $handle] {
				bMotionDoAction $channel $nick "%VAR{thanks}"
				bMotionDoAction $channel $nick "%BOT[@$handle,VAR{welcomes}]"
			} else {
				bMotionDoAction $channel $nick "%VAR{opped}"
			}
		} else {
			bMotion_putloglev d * "Not responding to +o in $channel as I was only deopped $diff seconds ago"
		}
		bMotion_plugins_settings_set "system" "optime" $channel "" [clock seconds]
		return 0
	}

	if {$mode == "-o"} {
		if {![wasop $botnick $channel]} {
			return 0
		}

		# stop this spamming so much; won't do anything unless we were opped > 15mins ago
		set optime [bMotion_plugins_settings_get "system" "optime" $channel ""]
		set diff 901
		if {$optime != ""} {
			set diff [expr [clock seconds] - $optime]
		}
		if {$diff > 900} {
			bMotionDoAction $channel $nick "%VAR{deopped}"
		} else {
			bMotion_putloglev d * "Not responding to -o in $channel as I was only opped $diff seconds ago"
		}
		bMotion_plugins_settings_set "system" "deoptime" $channel "" [clock seconds]
		return 0
	}

	#removed voice stuff because there is no "wasvoice" function

}

### bMotion_event_nick
proc bMotion_event_nick { nick host handle channel newnick } {

#check our global toggle
	global bMotionGlobal bMotionCache

	if {$bMotionGlobal == 0} {
		return 0
	}

	if {![channel get $channel bmotion]} {
		return 0
	}

	if [matchattr $handle J] {
		return 0
	}

	if {[isbotnick $nick] || [isbotnick $newnick]} {
		bMotion_putloglev d * "My nick has changed, recompiling regexps"
		set bMotionCache(compiled) 0
		bMotion_compile_matches
		return
	}

	#set nick [bMotion_cleanNick $nick $handle]
	#set newnick [bMotion_cleanNick $newnick $handle]

	return [bMotionDoEventResponse "nick" $nick $host $handle $channel $newnick ]
}

bMotion_putloglev d * "bMotion: events module loaded"
