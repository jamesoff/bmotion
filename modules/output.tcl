#bMotion - Output functions
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

set bMotion_output_delay 0

#
# pick a random element from a list
proc pickRandom { list } {
	bMotion_putloglev 5 * "pickRandom ($list)"
	return [lindex $list [rand [llength $list]]]
}

#
# get the pronoun for our gender
proc getPronoun {} {
	bMotion_putloglev 5 * "getPronoun"
	set gender [bMotion_setting_get "gender"]

	switch $gender {
		"male" {
			return "himself"
		}
		"female" {
			return "herself"
		}
		default {
			return "its"
		}
	}
}

#
# get "his" or "hers" for our gender
proc getHisHers {} {
	bMotion_putloglev 5 * "getHisHers"

	set gender [bMotion_setting_get "gender"]

	switch $gender {
		"male" {
			return "his"
		}
		"female" {
			return "hers"
		}
		default {
			return "its"
		}
	}
}

#
# get "her" or "her" for our gender
proc getHisHer {} {
	bMotion_putloglev 5 * "getHisHer"

	set gender [bMotion_setting_get "gender"]

	switch $gender {
		"male" {
			return "his"
		}
		"female" {
			return "her"
		}
		default {
			return "it"
		}
	}
}

#
# get "he" or "she" for our gender
proc getHeShe {} {
	bMotion_putloglev 5 * "getHeShe"

	set gender [bMotion_setting_get "gender"]

	switch $gender {
		"male" {
			return "he"
		}
		"female" {
			return "she"
		}
		default {
			return "it"
		}
	}
}

#
# do a /me action
proc mee {channel action {urgent 0} } {
	bMotion_putloglev 5 * "mee ($channel, $action, $urgent)"
	set channel [chandname2name $channel]
	regsub "^\"(.+)\"?$" $action {\1} action
	if {([string index $action 0] != ".") && (![regexp -nocase "^is" $action]) && ([rand 10] == 0)} {
		set action "*$action*"
	} else {
		set action "\001ACTION $action\001"
	}

	if {$urgent} {
		bMotion_queue_add_now $channel $action
	} else {
		bMotion_queue_add $channel $action
	}
}

proc bMotion_process_macros { channel text } {

	set done 0
	set current_pos 0
	while {$done == 0} {
		bMotion_putloglev d * "macro: starting loop with $text and current pos=$current_pos"
		set current_pos [string first "%" $text $current_pos]
		if {$current_pos == -1} {
		# no more matches
			set done 1
			continue
		} 
		bMotion_putloglev d * "macro: found a % at $current_pos"
		if {$current_pos < [string length $text]} {
		# this isn't a % at the end of the line
			if {[string index $text [expr $current_pos + 1]] == "|"} {
				set current_pos [expr $current_pos + 2]
				continue
			}

			#find the element following this %
			set substring [string range $text $current_pos end]
			if [regexp -nocase {%([a-z]+)} $substring matches macro] {
				bMotion_putloglev d * "macro: found macro $macro at $current_pos"
				set plugin [bMotion_plugin_find_output "en" "" 0 10 $macro]
				if {[llength $plugin] == 1} {
				# call plugin
					bMotion_putloglev d * "macro: found matching plugin for macro [lindex $plugin 0]"
					set result ""
					catch {
						set result [[lindex $plugin 0] $channel $text]
						if {$result == ""} {
							bMotion_putloglev d * "macro: [lindex $plugin 0] returned nothing, aborting output"
							return ""
						}
					}
					if {$result == ""} {
						return ""
						incr current_pos
						continue
					}

					if {$text != $result} {
						set text $result
						# reset current pos
						set current_pos 0
						continue
					} else {
						bMotion_putloglev d * "macro: [lindex $plugin 0] did nothing at position $current_pos in output $text"
					}
				} else {
					bMotion_putloglev d * "macro: unexpectly got too many matching plugins back: $plugin"
					incr current_pos
					continue
				}

				incr current_pos
				continue
			} else {
				bMotion_putloglev d * "macro: couldn't find a macro in $substring"
				# skip it
				incr current_pos
				continue
			}
		}

		# hmm
		bMotion_putloglev d * "macro: got to end of macro loop o_O"
		incr current_pos
	}

	return $text
}

#
# our magic output function
proc bMotionDoAction {channel nick text {moreText ""} {noTypo 0} {urgent 0} } {
	bMotion_putloglev 5 * "bMotionDoAction($channel,$nick,$text,$moreText,$noTypo,$urgent)"
	global bMotionInfo bMotionCache bMotionOriginalInput
	global bMotion_output_delay bMotionSettings BMOTION_SLEEP

	set bMotion_output_delay 0

	#check our global toggle
	global bMotionGlobal
	if {$bMotionGlobal == 0} {
		return 0
	}

	set bMotionCache($channel,last) 1

	# check if we're asleep
	if {[bMotion_setting_get "asleep"] == $BMOTION_SLEEP(ASLEEP)} {
		return 0
	}

	if [regexp "^\[#!\].+" $channel] {
		set channel [string tolower $channel]
		if {![channel get $channel bmotion]} {
			bMotion_putloglev d * "bMotion: aborting bMotionDoAction ... $channel not allowed"
			return 0
		}
	}

	if {[bMotion_setting_get "silence"] == 1} { 
		return 0 
	}
	catch {
		if {$bMotionInfo(adminSilence,$channel) == 1} { 
			return 0 
		}
	}

	switch [rand 3] {
		0 { }
		1 { set nick [string tolower $nick] }
		2 { set nick "[string range $nick 0 0][string tolower [string range $nick 1 end]]" }
	}

	# Process macros

	set original_line $text
	set done 0
	while {$done == 0} {
		set text [bMotion_process_macros $channel $text]

		set text [bMotionDoInterpolation $text $nick $moreText $channel]

		if {$text == $original_line} {
			set done 1
		} else {
			set original_line $text
			bMotion_putloglev d * "output: going round macro loop again"
		}
	}

	# now the rest
	if {$noTypo == 0} {
		set plugins [bMotion_plugin_find_output $bMotionInfo(language) $channel 11]
		if {[llength $plugins] > 0} {
			foreach callback $plugins {
				bMotion_putloglev 1 * "bMotion: output plugin: $callback..."
				set result ""
				catch {
					set result [$callback $channel $text]
				} err
				bMotion_putloglev 3 * "bMotion: returned from output $callback ($result)"
				if {$result == ""} {
					return 0
				}
				set text $result
			}
		}
	}

	# clear this in case a plugin ended up not using it in an abstract
	bMotion_plugins_settings_set "system" "ruser_skip" $channel "" ""

	#make sure the line wasn't set to blank by a plugin (may be trying to block output)
	set line [string trim $text]
	if {$line == ""} {
		return 0
	}

	# Explode line into lines
	# We map %| to NUL and split on that, since [split] can't
	# handle multichar boundaries
	set lines [split [string map [list "%|" \x00] $line] \x00]

	foreach lineIn $lines {
		set temp [bMotionSayLine $channel $nick $lineIn $moreText $noTypo $urgent]
		if {$temp == 1} {
			bMotion_putloglev 1 * "bMotion: bMotionSayLine returned 1, skipping rest of output"
			#1 stops continuation after a failed %bot[n,]
			break
		}
		#set typosDone [bMotion_plugins_settings_get "output:typos" "typosDone" "" ""]
		#bMotion_putloglev 2 * "bMotion: typosDone is !$typosDone!"
		## TODO: fix this
		#if {$typosDone != ""} {
		#	bMotion_plugins_settings_set "output:typos" "typosDone" "" "" ""
		#	if [rand 2] {
		#		bMotionDoAction $channel "" "%VAR{typoFix}" "" 1
		#	}
		#	bMotion_plugins_settings_set "output:typos" "typos" "" "" ""
		#}
	}
	return 0
}


# 
# replace things on lines
proc bMotionDoInterpolation { line nick moreText { channel "" } } {
	bMotion_putloglev 5 * "bMotionDoInterpolation: line = $line, nick = $nick, moreText = $moreText, channel = $channel"
	global botnick bMotionCache

	bMotion_putloglev 4 * "doing misc interpolation processing for $line"
	set line [bMotionInsertString $line "%%" $nick]
	set line [bMotionInsertString $line "%2" $moreText]
	set line [bMotionInsertString $line "%percent" "%"]

	bMotion_putloglev 4 * "bMotionDoInterpolation returning: $line"
	return $line
}

#
# more replacements in a line
# TODO: why was this separate?
proc bMotionInterpolation2 { line } {
	bMotion_putloglev 5 * "bMotionInterpolation2 ($line)"

	return $line
}

#
# Process a line
# TODO: why is this separate or at least such a mess :)
proc bMotionSayLine {channel nick line {moreText ""} {noTypo 0} {urgent 0} } {
	bMotion_putloglev 5 * "bMotionSayLine: channel = $channel, nick = $nick, line = $line, moreText = $moreText, noTypo = $noTypo"
	global mood botnick bMotionInfo bMotionCache bMotionOriginalInput
	global bMotion_output_delay

	#TODO: Put %ruser and %rbot back in here
	# XXX: is the above TODO still valid?

	#if it's a bot , put it on the queue on the remote bot
	if [regexp -nocase {%(BOT)\[(.+?)\]} $line matches botcmd cmd] {
		set condition ""
		set dobreak 0
		if {$botcmd == "bot"} {
		#random
			bMotion_putloglev 1 * "bMotion: %bot detected"
			regexp {%bot\[([[:digit:]]+),(@[^,]+,)?(.+)\]} $line matches chance condition cmd
			bMotion_putloglev 1 * "bMotion: %bot chance is $chance"
			set dobreak 1
			if {[rand 100] < $chance} {
				set line "%BOT\[$cmd\]"
				set dobreak 0
			} else {
				set line ""
			}
		} else {
		#non-random
			regexp {%BOT\[(@[^,]+,)?(.+)\]} $line matches condition cmd
		}

		if {($condition != "") && [regexp {^@(.+),$} $condition matches c]} {
			set condition $c
		} else {
			if {$condition != ""} {
				set cmd $condition
				set condition ""
			}
		}

		if {$line != ""} {
			set bot [bMotion_choose_random_user $channel 1 $condition]
			bMotion_putloglev 1 * "bMotion: queuing botcommand !$cmd! for output to $bot"
			bMotion_queue_add $channel "@${bot}@$cmd"
		}

		if {$dobreak == 1} {
			return 1
		}
		return 0
	}

	#if it's a %STOP, abort this
	if {$line == "%STOP"} {
		set line ""
		return 1
	}

	if [regexp {%DELAY\{([0-9]+)\}} $line matches delay] {
		set bMotion_output_delay $delay
		bMotion_putloglev d * "Changing output delay to $delay"
		set line ""
	}

	if {$mood(stoned) > 3} {
		if [rand 2] {
			set line "$line man.."
		} else {
			if [rand 2] {
				set line "$line dude..."
			}
		}
	}

	if {[string index $line end] == " "} {
		set line [string range $line 0 end-1]
	}

	#check if this line matches the last line said on IRC
	global bMotionThisText
	if [string match -nocase $bMotionThisText $line] {
		bMotion_putloglev 1 * "bMotion: my output matches the trigger, dropping"
		return 0
	}

	#protect this block - it'll generate an error if noone's talked yet, and then
	#we try an admin plugin
	if [info exists bMotionOriginalInput] {
		if [string match -nocase $bMotionOriginalInput $line] {
			bMotion_putloglev 1 * "my output matches the trigger, dropping"
			return 0
		}
	}

	set line [bMotionInsertString $line "%slash" "/"]

	global bMotion_output_delay

	if [regexp "^/" $line] {
	#it's an action
		mee $channel [string range $line 1 end] $urgent
	} else {
		if {$urgent} {
			bMotion_queue_add_now [chandname2name $channel] $line
		} else {
			bMotion_queue_add [chandname2name $channel] $line $bMotion_output_delay
		}
	}
	return 0
}

#
# Helper function to swap one thing (like a macro) for another
proc bMotionInsertString {line swapout toInsert} {
	bMotion_putloglev 5 * "bMotionInsertString ($line, $swapout, $toInsert)"
	set loops 0
	set inputLine $line
	while {[regexp $swapout $line]} {
		regsub $swapout $line $toInsert line
		incr loops
		if {$loops > 10} {
			putlog "bMotion: ALERT! Bailed in bMotionInsertString with $inputLine (created $line) (was changing $swapout for $toInsert)"
			set line "/has a tremendous failure :("
			return $line
		}
	}
	return $line
}

#
# Get random chars as would be made by shift-numberkeys
proc bMotionGetColenChars {} {
	bMotion_putloglev 5 * "bMotionGetColenChars"
	set randomChar "!£$%^*@#~"

	set randomChars [split $randomChar {}]

	set length [rand 12]
	set length [expr $length + 5]

	set line ""

	while {$length >= 0} {
		incr length -1
		append line [pickRandom $randomChars]
	}

	regsub -all "%" $line "%percent" line

	return $line
}

#
# make a smiley representing our mood
# TOOD: still used?
proc makeSmiley { mood } {
	bMotion_putloglev 5 * "makeSmiley"
	if {$mood > 30} {
		return ":D"
	}
	if {$mood > 0} {
		return ":)"
	}
	if {$mood == 0} {
		return ":|"
	}
	if {$mood < -30} {
		return ":C"
	}
	if {$mood < 0} {
		return ":("
	}
	return ":?"
}

#
# Attempt to clean a nickname up to a proper name
proc bMotionWashNick { nick } {
	bMotion_putloglev 5 * "bMotionWashNick ($nick)"
	#remove leading
	regsub {^[|`_\[]+} $nick "" nick

	#remove trailing
	regsub {[|`_\[]+$} $nick "" nick

	return $nick
}

#
# replace a nick with one of someone's IRL names
# TODO: no longer used? if not, delete
proc OLDbMotionGetRealName { nick { host "" }} {
	bMotion_putloglev 5 * "bMotion: OLDbMotionGetRealName($nick,$host)"

	#is it me?
	global botnicks
	set first {\m}
	set last {\M}
	if [regexp -nocase "${first}${botnicks}$last" $nick] {
		return "me"
	}

	#first see if we've got a handle
	if {![validuser $nick]} {
		bMotion_putloglev 2 * "bMotion: getRealName not given a handle, assuming $nick!$host"
		set host "$nick!$host"

		set handle [finduser $host]
		if {$handle == "*"} {
		#not in bot
			bMotion_putloglev 2 * "bMotion: no match, washing nick"
			return [bMotionWashNick $nick]
		}
	} else {
		set handle $nick
	}

	bMotion_putloglev 2 * "bMotion: getRealName looking for handle $handle"

	# found a user, now get their real name
	set realname [getuser $handle XTRA irl]
	if {$realname == ""} {
	#not set
		return [bMotionWashNick $nick]
	}
	bMotion_putloglev 2 * "bMotion: found $handle, IRLs are $realname"
	return [pickRandom $realname]
}

#
# replace a nick with one of someone's IRL names
proc bMotionGetRealName { nick { host "" }} {
	bMotion_putloglev 5 * "bMotion: bMotionGetRealName($nick,$host)"

	if {$nick == ""} {
		return ""
	}

	#is it me?
	if [isbotnick $nick] {
		return "me"
	}

	if [validuser $nick] {
	#it's a handle already
		set handle $nick
	} else {
	#try to figure it out
		set handle [nick2hand $nick]
		if {($handle == "") ||($handle == "*")} {
		#not in bot
			bMotion_putloglev 2 * "bMotion: no match, using nick"
			return $nick
		}
	}

	bMotion_putloglev 2 * "bMotion: $nick is handle $handle"

	# found a user, now get their real name
	set realname [getuser $handle XTRA irl]
	if {$realname == ""} {
	#not set
		bMotion_putloglev 2 * "no IRL set, using nick"
		return $nick
	}
	
	bMotion_putloglev 2 * "bMotion: IRLs for $handle are $realname"
	
	set chosen_realname [pickRandom $realname]

	if {[string first "%" $chosen_realname] > -1} {
		bMotion_putloglev d * "not using $chosen_realname for $handle as it has a macro"
		set chosen_realname $handle
	}
	return $chosen_realname
}

#
#
proc bMotionTransformNick { target nick {host ""} } {
	bMotion_putloglev 5 * "bMotionTransformNick($target, $nick, $host)"
	set newTarget [bMotionTransformTarget $target $host]
	if {$newTarget == "me"} {
		set newTarget $nick
	}
	return $newTarget
}

#
#
proc bMotionTransformTarget { target {host ""} } {
	bMotion_putloglev 5 * "bMotionTransformTarget($target, $host)"
	global botnicks
	if {$target != "me"} {
		set t [bMotionGetRealName $target $host]
		bMotion_putloglev 2 * "bMotion: bMotionGetName in bMotionTransformTarget returned $t"
		if {$t != "me"} {
			set target $t
		}
	} else {
		set himself {\m(your?self|}
		append himself $botnicks
		append himself {)\M}
		if [regexp -nocase $himself $target] {
			set target [getPronoun]
		}
	}
	return $target
}

# bMotion_choose_random_user
#
# selects a random user or bot from a channel
# bot = 0 if you want a user, = 1 if you want a bot
# condition is one of:
#		* "" - anyone
#		* male, female - pick by gender
#		* like, dislike - pick by if we'd do them
#		* friend, enemy - pick by if we're friends
#		* prev - return previously chosen user/bot
proc bMotion_choose_random_user { channel bot condition } {
	bMotion_putloglev 5 * "ruser: bMotion_choose_random_user ($channel, $bot, $condition)"
	global bMotionCache
	set users [chanlist $channel]
	set acceptable [list]

	set skip_nick [bMotion_plugins_settings_get "system" "ruser_skip" $channel ""]
	bMotion_plugins_settings_set "system" "ruser_skip" $channel "" ""
	if {$skip_nick != ""} {
		bMotion_putloglev d * "ruser skipping $skip_nick"
	}

	#check if we want the previous ruser
	if {$condition == "prev"} {
		set what [list "" ""]
		catch {
			set what [array get bMotionCache "lastruser$bot"]
		}
		bMotion_putloglev 4 * "ruser: accept: prev ($what)"
		return [lindex $what 1]
	}

	foreach user $users {
		bMotion_putloglev 4 * "ruser: eval user $user"
		#is it me?
		if [isbotnick $user] { 
			bMotion_putloglev 4 * "ruser:  that's me"
			continue 
		}

		if {([bMotion_setting_get "bitlbee"] == "1") && ($user == "root")} {
			bMotion_putloglev 4 * "ruser:  reject: bitlbee root user"
			continue
		}

		if {$user == $skip_nick} {
			bMotion_putloglev 4 * "ruser:  reject: $user is skip_user"
			continue
		}

		#get their handle
		set handle [nick2hand $user $channel]
		bMotion_putloglev 4 * "ruser:  handle: $handle"

		# some people don't like interacting with the bot
		if [matchattr $handle J] {
			bMotion_putloglev 4 * "ruser:  reject: user is +J"
			continue
		}

		#unless we're looking for any old user, we'll need handle
		if {(($handle == "") || ($handle == "*")) && ($condition != "")} {
			bMotion_putloglev 4 * "ruser:  reject: no handle"
			continue
		}

		#else, if we're accepting anyone and they don't have a handle, and
		#we don't want a bot, then use nick
		if {(($handle == "") || ($handle == "*")) && ($condition == "") && ($bot == 0)} {
			bMotion_putloglev 4 * "ruser:  accept: $user (no handle)"
			lappend acceptable $user
			continue
		}

		#if we're looking for a bot, drop this entry if it's not one
		if {$bot == 1} {
			if {![matchattr $handle b]} {
				bMotion_putloglev 4 * "ruser:  reject: not a bot"
				continue
			}
			#check we can talk to this bot
			global bMotion_interbot_otherbots
			if {[lsearch [array names bMotion_interbot_otherbots] $handle] == -1} {
				bMotion_putloglev 4 * "ruser:  reject: not a bmotion bot"
				continue
			}
			#else add them
			lappend acceptable $user
			bMotion_putloglev 4 * "ruser:  accept: bmotion bot"
			continue
		}

		#conversely if we're looking for a user...
		if {($bot == 0) && [matchattr $handle b]} {
			bMotion_putloglev 4 * "ruser:  reject: not a user"
			continue
		}

		switch $condition {
			"" {
				bMotion_putloglev 4 * "ruser:  accept: any"
				lappend acceptable $handle
				continue
			}
			"male" {
				if {[getuser $handle XTRA gender] == "male"} {
					bMotion_putloglev 4 * "ruser:  accept: male"
					lappend acceptable $handle
					continue
				}
			}
			"female" {
				if {[getuser $handle XTRA gender] == "female"} {
					bMotion_putloglev 4 * "ruser:  accept: female"
					lappend acceptable $handle
					continue
				}
			}
			"like" {
				if {[bMotionLike $user [getchanhost $user]]} {
					bMotion_putloglev 4 * "ruser:  accept: like"
					lappend acceptable $handle
					continue
				}
			}
			"dislike" {
				if {![bMotionLike $user [getchanhost $user]]} {
					bMotion_putloglev 4 * "ruser:  accept: dislike"
					lappend acceptable $handle
					continue
				}
			}
			"friend" {
				if {[getFriendshipHandle $handle] >= 50} {
					bMotion_putloglev 4 * "ruser:  accept: friend"
					lappend acceptable $handle
					continue
				}
			}
			"enemy" {
				if {[getFriendshipHandle $handle] < 50} {
					bMotion_putloglev 4 * "ruser:  accept: enemy"
					lappend acceptable $handle
					continue
				}
			}
		}
	}
	bMotion_putloglev 4 * "ruser: acceptable users: $acceptable"
	if {[llength $acceptable] > 0} {
		set user [pickRandom $acceptable]
		set index "lastruser$bot"
		set bMotionCache($index) $user
		return $user
	} else {
		bMotion_putloglev 4 * "ruser: no acceptable users found"
		if {$condition != ""} {
			bMotion_putloglev 4 * "ruser: picking a random user"
			return [bMotion_choose_random_user $channel $bot ""]
		} else {
			bMotion_putloglev 4 * "ruser: unable to find a user, returning nothing"
			return ""
		}
	}
}

#
# turn a name into the posessive form
proc bMotionMakePossessive { text { altMode 0 }} {
	bMotion_putloglev 5 * "bMotionMakePossessive ($text, $altMode)"
	if {$text == ""} {
		return "someone's"
	}

	if {$text == "me"} {
		if {$altMode == 1} {
			return "mine"
		}
		return "my"
	}

	if {$text == "you"} {
		if {$altMode == 1} {
			return "yours"
		}
		return "your"
	}

	if [regexp -nocase "s$" $text] {
		return "$text'"
	}
	return "$text's"
}

#
# Function which powers %REPEAT
proc bMotionMakeRepeat { text } {
	bMotion_putloglev 5 * "bMotionMakeRepeat ($text)"
	if [regexp {([0-9]+):([0-9]+):(.+)} $text matches min max repeat] {
		bMotion_putloglev 4 * "bMotionMakeRepeat: min = $min, max = $max, text = $repeat"
		set diff [expr $max - $min]
		if {$diff < 1} {
			set diff 1
		}
		set count [rand $diff]
		set repstring [string repeat $repeat $count]
		append repstring [string repeat $repeat $min]
		return $repstring
	}
	bMotion_putloglev 4 * "bMotionMakeRepeat: no match (!), returning nothing"
	return ""
}

#
# remove preceeding fluff from a noun
proc bMotion_strip_article { text } {
	bMotion_putloglev 5 * "bMotion_strip_article ($text)"
	regsub "(an?|the|some|his|her|their) " $text "" text
	return $text
}

#
# verbs a noun (like that)
proc bMotionMakeVerb { text } {
	bMotion_putloglev 5 * "bMotionMakeVerb ($text)"
	if [regexp -nocase "(s|x)$" $text matches letter] {
		return $text
	}

	if [regexp -nocase "^(.*)y$" $text matches root] {
		set verb $root
		append verb "ies"
		return $verb
	}

	append text "s"
	return $text
}

#
# makes a word past tense... probably best only use it on verbs :P
proc bMotion_make_past_tense { word } {

	# check if we got passed a multi-part verb (sit on)
	set extra ""
	regexp -nocase {^(\w+)( (.+))?} $word matches verb extra
	set newverb ""

	# handle irregual verbs
	switch $verb {
		cut { set newverb $verb }
		hit { set newverb $verb }
		fit { set newverb $verb }
		get { set newverb got }
		sit { set newverb sat }
		drink { set newverb drank }
		catch { set newverb caught }
		bring { set newverb brought }
		buy { set newverb bought}
		teach { set newverb taught }
		have { set newverb had }
		do { set newverb did }
		ride { set newverb rode }
		go { set newverb went }
		make { set newverb made }
	}

	if {$newverb != ""} {
		return "${newverb}$extra"
	}

	# verbs ending in e get -ed
	if [string match -nocase "*e" $verb] {
		append verb "d"
		set newverb $verb
	}

	if {$newverb != ""} {
		return "${newverb}$extra"
	}

	# ending in const-y get -ied
	if [regexp -nocase {(.+[^aeiouy])y$} $verb matches a] {
		set newverb "${a}ied"
	}

	if {$newverb != ""} {
		return "${newverb}$extra"
	}

	# one vowel + const !wy get double const + ed
	if [regexp -nocase {(.+[^aeiouy][aeiou])([^aeiouwy])\M} $verb matches a b] {
		set newverb "${a}${b}${b}ed"
	}

	if {$newverb != ""} {
		return "${newverb}$extra"
	}

	# everything else just gets -ed
	set newverb "${verb}ed"

	return "${newverb}$extra"
}

#
# makes a word into present participle
proc bMotion_make_present_participle { word } {

	# check if we got passed a multi-part verb (sit on)
	set extra ""
	regexp -nocase {^(\w+)( (.+))?} $word matches verb extra

	if [regexp -nocase {(.+[^i])e$} $verb matches a] {
		return "${a}ing$extra"
	}

	if [regexp -nocase {(.+[aeiou])([^aeiouy])$} $verb matches a b] {
		return "${a}${b}${b}ing$extra"
	}

	return "${verb}ing$extra"
}

#
# makes a work into the simple present
proc bMotion_make_simple_present { word } {

	# check if we got passed a multi-part verb (sit on)
	set extra ""
	regexp -nocase {^(\w+)( (.+))?} $word matches verb extra

	return "${verb}s$extra"
}

#
# not sure!
proc chr c {
	if {[string length $c] > 1 } { error "chr: arg should be a single char"}
	#		set c [ string range $c 0 0]
	set v 0
	scan $c %c v
	return $v
}

#
# pluralise a noun by the simple rules of English
proc bMotionMakePlural { text } {
	bMotion_putloglev 5 * "bMotionMakePlural ($text)"

	if [regexp -nocase "(ss|ts|us|is|x|ch|sh)$" $text] {
		append text "es"
		return $text
	}

	if [regexp -nocase "s$" $text] {
		return $text
	}

	if [regexp -nocase "^(.*)f$" $text matches root] {
		set plural $root
		append plural "ves"
		return $plural
	}

	if [regexp -nocase "^(.*)y$" $text matches root] {
		set plural $root
		append plural "ies"
		return $plural
	}

	append text "s"
	return $text

}

bMotion_putloglev d * "bMotion: output module loaded"
