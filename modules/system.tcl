# bMotion - System functions
#
# vim: foldmethod=marker:foldmarker=<<<,>>>:foldcolumn=3

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2002
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


### init our counters <<<1
bMotion_counter_init "system" "randomstuff"


### Set up the binds <<<1

#General IRC events <<<2
bind join - *!*@* bMotion_event_onjoin
bind mode - * bMotion_event_mode
bind pubm - * bMotion_event_main
bind sign - * bMotion_event_onquit
bind nick - * bMotion_event_nick
bind part - * bMotion_event_onpart
bind ctcp - ACTION bMotion_event_action

#bMotion IRC events <<<2
bind pub - "!mood" pubm_moodhandler
bind pub - "!bminfo" bMotionInfo
bind pub - "!bmstats" bMotionStats
bind msg - bmotion msg_bmotioncommand
bind pub - !bmadmin bMotionAdminHandler
bind pub - !bmotion bMotionAdminHandler2
bind pub - .bmotion bMotionAdminHandler2

#DCC commands <<<2
bind dcc m mood moodhandler
bind dcc m bmotion* bMotion_dcc_command
bind dcc m bmadmin* bMotion_dcc_command
bind dcc m bmhelp bMotion_dcc_help

#bedtime
bind time - "* * * * *" bMotion_check_tired2

### bMotion_update_chanlist <<<1
# rebuilds our channel list based on which channels are +bmotion
proc bMotion_update_chanlist { } {
	global bMotionChannels
	set bMotionChannels [list]

	foreach chan [channels] {
		if {[channel get $chan bmotion]} {
			lappend bMotionChannels $chan
		}
	}
}
### Initalise some variables per channel <<<1
bMotion_update_chanlist
foreach chan $bMotionChannels {
	set bMotionLastEvent($chan) [clock seconds]
	set bMotionInfo(adminSilence,$chan) 0
	#set to 1 when the bot says something, and 0 when someone else says something
	#used to make the bot a bit more intelligent (perhaps) at conversations
	set bMotionCache($chan,last) 0
	#channel mood tracker
	#set bMotionCache($chan,mood) 0
}

### bMotionStats <<<1
proc bMotionStats {nick host handle channel text} {
	global bMotionInfo botnicks bMotionSettings cvsinfo botnick
	global bMotionVersion
	if {(![regexp -nocase $botnick $text]) && ($text != "all")} { return 0 }
	if {!([isvoice $nick] || [isop $nick]) || ($nick != "JamesOff")} { return 0 }


	global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age
	global bMotion_abstract_ondisk

	set mem [llength [array names bMotion_abstract_contents]]
	set disk [llength $bMotion_abstract_ondisk]
	set faults [bMotion_counter_get "abstracts" "faults"]
	set pageouts [bMotion_counter_get "abstracts" "pageouts"]
	global bMotionFacts
	set items [lsort [array names bMotionFacts]]
	set itemcount 0
	set factcount 0
	foreach item $items {
		incr itemcount
		incr factcount [llength $bMotionFacts($item)]
	}

	putchan $channel "abstracts: [expr $mem + $disk] total, $mem loaded, $disk on disk, $faults faults, $pageouts pageouts. [bMotion_counter_get abstracts gc] garbage collections, [bMotion_counter_get abstracts gets] fetches"
	putchan $channel "facts: $factcount facts about $itemcount items"
	putchan $channel "plugins fired: simple [bMotion_counter_get events simpleplugins], complex [bMotion_counter_get events complexplugins]"
	putchan $channel "output: lines sent to output: [bMotion_counter_get output lines], lines sent to irc: [bMotion_counter_get output irclines]"
	putchan $channel "system: randomness: [bMotion_counter_get system randomstuff]"
	putchan $channel "flood: checks: [bMotion_counter_get flood checks]"
}



# check if a channel is active enough for randomy things
proc bMotion_is_active_enough { channel { limit 0 } } {
	global bMotionInfo 
	global bMotionLastEvent 

	bMotion_putloglev 4 * "bMotion_is_active_enough $channel"

	set last_event 0
	catch {
		set last_event $bMotionLastEvent($channel)
	}
	if {$last_event == 0} {
		bMotion_putloglev d * "last event info for $channel not available"
		# assume we're ok
		return 1
	}

	bMotion_putloglev 3 * "last event for $channel was $last_event"
	if {$limit == 0} {
		set limit [expr $bMotionInfo(maxIdleGap) * 60]
	}

	if {([clock seconds] - $last_event) < $limit} {
		bMotion_putloglev 3 * "it fits!"
		return 1
	}
	return 0
}

# check if every channel we can see is idle enough for us to go away
proc bMotion_random_away {} {
	global bMotionLastEvent bMotionChannels bMotionInfo 

	# check if it's worth doing anything
	if {[bMotion_setting_get "bitlbee"]} {
		#never go away in bitlbee
		return 0
	}

	#override if we should never go away
	if {[bMotion_setting_get "useAway"] != 1} {
		return 0
	}

	# find the least idle channel
	set mostRecent 0
	set line "comparing idle times: "
	foreach channel $bMotionChannels {
		catch {
			append line "$channel=$bMotionLastEvent($channel) "
			if {$bMotionLastEvent($channel) > $mostRecent} {
				set mostRecent $bMotionLastEvent($channel)
			}
		}
	}
	bMotion_putloglev 1 * "bMotion: most recent: $mostRecent .. timenow $timeNow .. gap [expr $bMotionInfo(maxIdleGap) * 10]"

	set idleEnough 1

	if {($timeNow - $mostRecent) < ([expr $bMotionInfo(maxIdleGap) * 10])} {
		set idleEnough 0
	}

	if {!$idleEnough} {
		return 0
	}

	if {$bMotionInfo(away) == 1} {
		#away, don't do anything (and don't do randomstuff)
		return 0
	}

	if {[rand 4] == 0} {
		putlog "bMotion: All channels are idle, going away"
		bMotionSetRandomAway
		return 0
	}
}

# periodically sprout randomness (or go /away if idle enough)
proc doRandomStuff {} {
	global bMotionInfo mood stonedRandomStuff bMotionSettings
	global bMotionLastEvent bMotionOriginalNick bMotionChannels
	global BMOTION_SLEEP

	set timeNow [clock seconds]
	set saidChannels [list]
	set silentChannels [list]
	set bMotionOriginalNick ""

	bMotion_update_chanlist

	# choose new time to check
	set upperLimit [expr $bMotionInfo(maxRandomDelay) - $bMotionInfo(minRandomDelay)]
	if {$upperLimit < 1} {
		set upperLimit 1
	}
	set temp [expr [rand $upperLimit] + $bMotionInfo(minRandomDelay)]
	timer $temp doRandomStuff
	bMotion_putloglev d * "bMotion: randomStuff next ($temp minutes)"

	# don't bother if we're asleep
	if {$bMotionSettings(asleep) != $BMOTION_SLEEP(AWAKE)} {
		bMotion_putloglev d * "not doing randomstuff now, i'm asleep"
		# kill any away status as we don't want to come back from the shops after we've been to bed :P
		set bMotionInfo(away) 0
		return
	}

	if [bMotion_random_away] {
		# we went away, so stop here
		return
	}

	if {$bMotionInfo(away) == 1} {
		#away and busy again, return
		bMotionSetRandomBack
	}

	if {[bMotion_setting_get "bitlbee"] == "1"} {
		return 0
	}

	# if someone spoke in the last 5 mins, use an activeRandomStuff
	# else use a randomStuff

	set active_idle_sec [bMotion_setting_get "active_idle_sec"]

	foreach channel $bMotionChannels {
		if [bMotion_is_active_enough $channel] {
			if [bMotion_is_active_enough $channel $active_idle_sec] {
				#channel is fairly busy
				if [bMotionSaySomethingRandom $channel 1] {
					lappend saidChannels "$channel/active"
				} else {
					lappend silentChannels $channel
				}
			} else {
				#use a more idle randomstuff
				if [bMotionSaySomethingRandom $channel 0] {
					lappend saidChannels $channel
				} else {
					lappend silentChannels $channel
				}
			}
		} else {
			lappend silentChannels $channel
		}
	}
	bMotion_putloglev d * "bMotion: randomStuff said ($saidChannels) silent ($silentChannels)"
}

### bMotionSaySomethingRandom <<<1
proc bMotionSaySomethingRandom {channel {busy 0}} {
	global randomStuff stonedRandomStuff mood bMotionInfo bMotionCache

	bMotion_putloglev 4 * "bMotionSaySomethingRandom $channel $busy"

	if {$busy} {
		set base_abstract "activeRandomStuff"
	} else {
		set base_abstract "randomStuff"
	}

	bMotion_putloglev d * "base abstract for randomness in $channel is $base_abstract"

	if [rand 2] {
		set today [clock format [clock seconds] -format "${base_abstract}_%Y_%m_%d"]
		if [bMotion_abstract_exists $today] {
			bMotion_putloglev d * "using abstract $today for randomstuff in $channel"
			bMotionDoAction $channel "" "%VAR{$today}"
			return 1
		}

		set today [clock format [clock seconds] -format "${base_abstract}_%m_%d"]
		if [bMotion_abstract_exists $today] {
			bMotion_putloglev d * "using abstract $today for randomstuff in $channel"
			bMotionDoAction $channel "" "%VAR{$today}"
			return 1
		}

		bMotion_putloglev d * "no special day abstract found for randomStuff in $channel"
		bMotionDoAction $channel "" "%VAR{${base_abstract}}"
		return 1
	}

	return 0
}


### bMotionSetRandomAway <<<1
proc bMotionSetRandomAway {} {
	#set myself away with a random message
	global randomAways bMotionInfo bMotionSettings bMotionChannels

	set awayReason [bMotion_abstract_get "randomAways"]
	foreach channel $bMotionChannels {
		if {[lsearch $bMotionSettings(noAwayFor) $channel] == -1} {
			bMotionDoAction $channel $awayReason "/is away: %%"
		}
	}
	putserv "AWAY :$awayReason"
	set bMotionInfo(away) 1
	set bMotionInfo(silence) 1
	bMotion_putloglev d * "bMotion: Set myself away: $awayReason"
	bMotion_putloglev d * "bMotion: Going silent"
}

### bMotionSetRandomBack <<<1
proc bMotionSetRandomBack {} {
	#set myself back
	global bMotionInfo bMotionSettings bMotionChannels

	bMotion_update_chanlist

	set bMotionInfo(away) 0
	set bMotionInfo(silence) 0
	foreach channel $bMotionChannels {
		if {[lsearch $bMotionSettings(noAwayFor) $channel] == -1} {
			bMotionDoAction $channel "" "/is back"
		}
	}
	putserv "AWAY"

	#elect cos we're available now
	bMotion_interbot_next_elect

	return 0
}

### bMotionTalkingToMe <<<1
proc bMotionTalkingToMe { text } {
	global botnicks

	bMotion_putloglev 2 * "checking $text to see if they're talking to me"
	if [regexp -nocase "^$botnicks\[ :,\]" $text] {
		bMotion_putloglev 2 * "`- yes"	
		return 1
	}

	if [regexp -nocase "$botnicks\[!?~\]*$" $text] {
		bMotion_putloglev 2 * "`- yes"	
		return 1
	}

	bMotion_putloglev 2 * "`- no"
	return 0
}

### bMotionSilence <<<1
# Makes the bot shut up
proc bMotionSilence {nick host channel} {
	global bMotionInfo silenceAways bMotionSettings
	if {$bMotionInfo(silence) == 1} {
		#I already am :P
		putserv "NOTICE $nick :I already am silent :P"
		return 0
	}
	timer $bMotionSettings(silenceTime) bMotionUnSilence
	putlog "bMotion: Was told to be silent for $bMotionSettings(silenceTime) minutes by $nick in $channel"
	bMotionDoAction $channel $nick "%VAR{silenceAways}"
	putserv "AWAY :afk ($nick $channel)"
	set bMotionInfo(silence) 1
	set bMotionInfo(away) 1
}

### bMotionUnSilence <<<1
# Undoes the shut up command
proc bMotionUnSilence {} {
	# Timer for silence expires
	putserv "AWAY"
	putlog "bMotion: No longer silent."
	global bMotionInfo
	set bMotionInfo(silence) 0
	set bMotionInfo(away) 0
}

### bMotionLike <<<1
proc bMotionLike {nick { host "" }} {
	global bMotionInfo mood bMotionSettings
	if {$host == ""} {
		set host [getchanhost $nick]
	}

	set host "$nick!$host"

	if {$bMotionSettings(melMode) == 1} {
		return 1
	}

	set handle [finduser $host]
	if {$handle == "*"} {
		# couldn't find a match
		#if i'm stoned enough, i'll sleep with anyone
		if {$mood(stoned) > 20} {
			return 1
		}

		#if i'm horny enough, i'll sleep with anyone
		if {$mood(horny) > 10} {
			return 1
		}
		#else they can get lost
		return 0
	}

	#don't like people who aren't my friends
	if {![bMotionIsFriend $nick]} { return 0 }

	# we're friends, now get their gender
	set gender [getuser $handle XTRA gender]
	if {$gender == ""} {
		# they don't have a gender. let's assume we'd have sex with them too
		return 1
	}
	if {$gender == $bMotionInfo(gender)} {
		#they're my gender
		if {($bMotionInfo(orientation) == "bi") || ($bMotionInfo(orientation) == "gay") || ($bMotionInfo(orientation) == "lesbian")} {
			return 1
		}
		return 0
	}
	#they're not my gender. what now?
	if {($bMotionInfo(orientation) == "bi") || ($bMotionInfo(orientation) == "straight")} {
		return 1
	}
	# that only leaves lesbian and gay who won't sleep with the opposite gender
	return 0
}

### bMotionGetGender <<<1
proc bMotionGetGender { nick host } {
	set host "$nick!$host"
	set handle [finduser $host]
	if {$handle == "*"} {
		return "unknown"
	}
	# found a user, now get their gender
	return [getuser $handle XTRA gender]
}

### getHour <<<1
proc getHour {} {
	return [clock format [clock seconds] -format "%H"]
}


### bMotion_dcc_command <<<1
proc bMotion_dcc_command { handle idx arg } {
	global bMotionInfo

	set cmd $arg

	bMotion_plugins_settings_set "admin" "type" "" "" "dcc"
	bMotion_plugins_settings_set "admin" "idx" "" "" $idx

	set nfo [bMotion_plugin_find_management $cmd]

	if {$nfo == ""} {
		bMotion_putadmin "what"
		return 1
	}

	set blah [split $nfo "¦"]
	set flags [lindex $blah 0]
	set callback [lindex $blah 1]

	if {![matchattr $handle $flags]} {
		bMotion_putadmin "What? You need more flags :)"
		return 1
	}

	bMotion_putloglev d * "bMotion: management callback matched, calling $callback"

	#strip the first command
	regexp {[^ ]+( .+)?} $cmd {\1} arg

	#run the callback :)
	set arg [join $arg]
	set arg [string trim $arg]

	catch {
		if {$arg == ""} {
			$callback $handle
		} else {
			$callback $handle $arg
		}
	} err
	if {($err != "") && ($err != 0)} {
		putlog "bMotion: ALERT! Callback failed for !bmotion: $callback: $err"
	} else {
		return 0
	}

	bMotion_putloglev 2 * "bMotion: admin command $arg from $handle"
	set info [bMotion_plugin_find_admin $arg $bMotionInfo(language)]
	if {$info == ""} {
		putidx $idx "Unknown command (or error). Try .bmotion help"
		return 1
	}

	set blah [split $info "¦"]
	set flags [lindex $blah 0]
	set callback [lindex $blah 1]

	if {![matchattr $handle $flags]} {
		putidx $idx "What? You need more flags :)"
		return 1
	}

	bMotion_putloglev d * "bMotion: admin callback matched, calling $callback"

	#strip the first command
	regexp {[^ ]+( .+)?} $arg {\1} arg

	#run the callback :)
	set arg [join $arg]
	set arg [string trim $arg]
	catch {
		if {$arg == ""} {
			$callback $handle $idx
		} else {
			$callback $handle $idx $arg
		}
	} err
	if {($err != "") && ($err != 0)} {
		putlog "bMotion: ALERT! Callback failed for .bmadmin: $callback ($handle $idx $arg)"
		putidx $idx "Sorry :( Running your callback failed ($err)\r"
	}
}

### bMotion_dcc_help <<<1
proc bMotion_dcc_help { handle idx arg } {
	putidx $idx "Please use .bmotion help"
	return 0
}


### new admin plugins ("management")
### bMotionAdminHandler2 <<<1
proc bMotionAdminHandler2 {nick host handle channel text} {
	global botnicks bMotionInfo botnick bMotionSettings

	#first, check botnicks (this is to get round empty-nick-on-startup
	if {$botnicks == ""} {
		# need to set this
		set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
	}

	if {![regexp -nocase "^($botnicks|all) (.+)" $text matches yarr bn cmd]} {
		#not me
		return 0
	}

	#regexp -nocase "^(($botnicks)|all) (.+)" $text matches blah blah2 blah3 cmd

	bMotion_plugins_settings_set "admin" "type" "" "" "irc"
	bMotion_plugins_settings_set "admin" "target" "" "" $channel

	#putlog "bMotion command from $nick in $channel: $cmd"
	set nfo [bMotion_plugin_find_management $cmd]

	if {$nfo == ""} {
		bMotion_putadmin "Unknown command (try .bmotion help)"
		return 1
	}

	set blah [split $nfo "¦"]
	set flags [lindex $blah 0]
	set callback [lindex $blah 1]

	if {![matchattr $handle $flags]} {
		bMotion_putadmin "What? You need more flags :)"
		return 1
	}

	bMotion_putloglev d * "bMotion: management callback matched, calling $callback"

	#strip the first command
	regexp {[^ ]+( .+)?} $cmd {\1} arg

	#run the callback :)
	set arg [join $arg]
	set arg [string trim $arg]

	catch {
		if {$arg == ""} {
			$callback $handle
		} else {
			$callback $handle $arg
		}
	} err
	if {($err != "") && ($err != 0)} {
		putlog "bMotion: ALERT! Callback failed for !bmotion: $callback: $err"
	}
}


### bMotion_putadmin <<<1
proc bMotion_putadmin { text } {

	set output [bMotion_plugins_settings_get "admin" "type" "" ""]
	if {$output == ""} {
		return 0
	}

	if {$output == "dcc"} {
		set idx [bMotion_plugins_settings_get "admin" "idx" "" ""]
		putidx $idx $text
		return 0
	}

	if {$output == "irc"} {
		set target [bMotion_plugins_settings_get "admin" "target" "" ""]
		puthelp "PRIVMSG $target :$text"
		return 0
	}
	return 0
}

### bMotionAdminHandler <<<1
#TODO: is this ever used now?
proc bMotionAdminHandler {nick host handle channel text} {
	global bMotionAdminFlag botnicks bMotionInfo botnick bMotionSettings

	if {![matchattr $handle $bMotionAdminFlag $channel]} {
		return 0
	}

	#first, check botnicks (this is to get round empty-nick-on-startup
	if {$botnicks == ""} {
		# need to set this
		set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
	}

	if [regexp -nocase "$botnicks (shut up|silence|quiet)" $text] {
		set bMotionInfo(adminSilence,$channel) 1
		puthelp "NOTICE $nick :OK, silent in $channel until told otherwise"
		return 1
	}

	if [regexp -nocase "$botnicks (end|cancel|stop) (shut up|silence|quiet)" $text] {
		set bMotionInfo(adminSilence,$channel) 0
		puthelp "NOTICE $nick :No longer silent in $channel"
		return 1
	}

	if [regexp -nocase "$botnicks washnick (.+)" $text matches bn nick2] {
		bMotionDoAction $channel $nick "%%: %2" [bMotionWashNick $nick2]
		return 1
	}

	if [regexp -nocase "$botnicks global (shut up|silence|quiet)" $text] {
		set bMotionInfo(silence) 1
		set bMotionInfo(away) 1
		puthelp "NOTICE $nick :Now globally silent"
		putserv "AWAY :Global silence requested by $nick"
		return 1
	}

	if [regexp -nocase "$botnicks (end|cancel|stop) global (shut up|silence|quiet)" $text] {
		set bMotionInfo(silence) 0
		set bMotionInfo(away) 0
		puthelp "NOTICE $nick :No longer globally silent"
		putserv "AWAY"
		return 1
	}

	if [regexp -nocase "$botnicks leet (on|off)" $text blah pop toggle] {

		if {$toggle == "off"} {
			putlog "bMotion: Leet mode off by $nick"
			set bMotionInfo(leet) 0
			bMotionDoAction $channel $nick "/stops talking like a retard."
			return 0
		}

		if {$toggle == "on"} {
			putlog "bMotion: Leet mode on by $nick"
			set bMotionInfo(leet) 1
			bMotionDoAction $channel $nick "Leet mode on ... fear my skills!"
		}
		return 1
	}

	if [regexp -nocase "$botnicks dutch (on|off)" $text blah pop toggle] {

		if {$toggle == "off"} {
			putlog "bMotion: Dutch mode off by $nick"
			set bMotionInfo(dutch) 0
			bMotionDoAction $channel $nick "/stops talking like a European."
			return 0
		}

		if {$toggle == "on"} {
			putlog "bMotion: Dutch mode on by $nick"
			bMotionDoAction $channel $nick "/snapt wel nederlands"
			set bMotionInfo(dutch) 1
		}
		return 1
	}


	if [regexp -nocase "$botnicks leetchance (.+)" $text blah pop value] {
		set bMotionInfo(leetChance) $value
		puthelp "NOTICE $nick :Ok"
		return 1
	}

	if [regexp -nocase "$botnicks reload" $text blah pop value] {
		puthelp "NOTICE $nick :Reloading random stuff lists"
		source scripts/bMotionRandoms.tcl
		putlog "bMotion: Reloaded bMotion randoms ($nick)"
		return 1
	}

	if [regexp -nocase "$botnicks parse (.+)" $text matches bot txt] {
		bMotionDoAction $channel $nick $txt
		putlog "bMotion: Parsed text for $nick"
		return 1
	}

	if [regexp -nocase "$botnicks su (.+?) (.+)" $text matches bot nick2 txt] {
		bMotion_event_main $nick2 [getchanhost $nick2 $channel] [nick2hand $nick2] $channel $txt
		putlog "bMotion: su to $nick2 by $nick on $channel: $txt"
		return 1
	}
}

### msg_bmotioncommand <<<1
proc msg_bmotioncommand { nick host handle cmd } {
	bMotion_plugins_settings_set "admin" "type" "" "" "irc"
	bMotion_plugins_settings_set "admin" "target" "" "" $nick

	regsub "(bmotion )" $cmd "" cmd
	set nfo [bMotion_plugin_find_management $cmd]

	if {$nfo == ""} {
		bMotion_putadmin "Unknown command (try .bmotion help)"
		return 1
	}

	set blah [split $nfo "¦"]
	set flags [lindex $blah 0]
	set callback [lindex $blah 1]

	if {![matchattr $handle $flags]} {
		bMotion_putadmin "What? You need more flags :)"
		return 1
	}

	bMotion_putloglev d * "bMotion: management callback matched, calling $callback"

	#strip the first command
	regexp {[^ ]+( .+)?} $cmd {\1} arg

	#run the callback :)
	set arg [join $arg]
	set arg [string trim $arg]

	catch {
		if {$arg == ""} {
			$callback $handle
		} else {
			$callback $handle $arg
		}
	} err
	if {($err != "") && ($err != 0)} {
		putlog "bMotion: ALERT! Callback failed for !bmotion: $callback"
	}
}

### bMotion_get_number <<<1
proc bMotion_get_number { num } {
	if {$num <= 0} {
		bMotion_putloglev d * "Warning: bMotion_get_number called with invalid parameter: $num"
		return 0
	}
	return [expr [rand $num] + 1]
}

### bMotion_rand_nonzero <<<1
proc bMotion_rand_nonzero { limit } {
	if {$limit <= 0} {
		return 0
	}

	incr limit 1
	set result [rand $limit]
	incr limit
	return $limit
}

### bMotion_startTimers <<<1
proc bMotion_startTimers { } {
	global mooddrifttimer
	if	{![info exists mooddrifttimer]} {
		timer 10 driftmood
		#utimer 5 loldec
		timer [expr [rand 30] + 3] doRandomStuff
		set mooddrifttimer 1
		set delay [expr [rand 200] + 1700]
		utimer $delay bMotion_interbot_next_elect
	}
}

### bMotion_cleanNick <<<1
proc bMotion_cleanNick { nick { handle "" } } {
	#attempt to clean []s etc out of nicks

	if {![regexp {[\\\[\]\{\}]} $nick]} {
		return $nick
	}

	if {($handle == "") || ($handle == "*")} {
		set handle [nick2hand $nick]
	}

	if {($handle != "") && ($handle != "*")} {
		set nick $handle
	}

	#have we STILL got illegal chars?
	if {[regexp {[\\\[\]\{\}]} $nick]} {
		return [string map { \[ "_" \] "_" \{ "_" \} "_" } $nick]
	}
	return $nick
}

### bMotion_uncolen <<<1
# clean out $£(($ off the end
proc bMotion_uncolen { line } {
	regsub -all {([!\"\£\$\%\^\&\*\(\)\#\@]{3,})} $line "" line
	return $line
}

### bMotion_setting_get <<<1
# get a setting out of the two variables that commonly hold them
proc bMotion_setting_get { setting } {
	global bMotionSettings
	global bMotionInfo
	set val ""
	catch {
		set val $bMotionSettings($setting)
	}
	if {$val != ""} {
		return $val
	}

	bMotion_putloglev 3 * "setting '$setting' doesn't exist in bMotionSettings, trying bMotionInfo..."
	catch {
		set val $bMotionInfo($setting)
	}
	if {$val != ""} {
		return $val

	}

	bMotion_putloglev 3 * "nope, not there either, returning nothing"
	return ""
}
#>>>
proc bMotion_check_botnicks { } {
	global botnicks bMotionSettings botnick

	if {$botnicks == ""} {
		set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
	}
}

proc bMotion_check_tired { min hour day month year } {
	global bMotionSettings BMOTION_SLEEP

	bMotion_putloglev 4 * "bMotion_check_tired $min $hour $day $month $year"
	if {[bMotion_setting_get "sleepy"] != 1} {
		return
	}

	set past_sleepy [bMotion_later_than $bMotionSettings(bedtime_hour) $bMotionSettings(bedtime_minute)]
	set past_wakey [bMotion_later_than $bMotionSettings(wakeytime_hour) $bMotionSettings(wakeytime_minute)]

	bMotion_putloglev 3 * "past_sleepy: $past_sleepy ... past_wakey: $past_wakey"

	if {$bMotionSettings(asleep) < $BMOTION_SLEEP(ASLEEP)} {
		# not asleep, so check if we should be
		set do_sleep 0
		if {$bMotionSettings(bedtime_hour) > $bMotionSettings(wakeytime_hour)} {
			# check that we're past wakeytime and sleepytime
			if {$past_wakey && $past_sleepy} {
				set do_sleep 1
			}
		} else {
			# check we're past sleepytime and NOT past wwakeytime (4am < X < 9am)
				if {$past_sleepy && !$past_wakey} {
				set do_sleep 1
			}
		}

		if {$do_sleep} {
			bMotion_putloglev d * "past my bedtime, going to sleep"
			bMotion_go_to_sleep
			return
		}
	} else {
		set do_wake 0
		if {$bMotionSettings(bedtime_hour) > $bMotionSettings(wakeytime_hour)} {
			# check we're not past bedtime but we are past wakeytime
			if {!$past_sleepy && $past_wakey} {
				set do_wake 1
			} else {
				# check we're past
				if {$past_sleepy && !$past_wakey} {
					set do_wake 1
				}
			}
		}

		if ($do_wake) {
			bMotion_putloglev d * "ooh, time to wake up"
			bMotion_wake_up
			return
		}
	}
}

# go to sleep
proc bMotion_go_to_sleep { } {
	# ok this is the plan
	# 1. announce we feel tired
	# 2. ???
	# 3. sleep
	global bMotionSettings BMOTION_SLEEP bMotionChannels
	bMotion_update_chanlist

	if {$bMotionSettings(asleep) == $BMOTION_SLEEP(AWAKE)} {
		bMotion_putloglev 3 * "considering awake -> bedtime"
		if {[rand 10] > 3} {
			# announce we're tired
			set bMotionSettings(asleep) $BMOTION_SLEEP(BEDTIME)
			putlog "bMotion: preparing to go to bed"
			foreach chan $bMotionChannels {
				if [bMotion_is_active_enough $chan] {
					bMotion_putloglev 3 * "sending tired output to $chan"
					bMotionDoAction $chan "" "%VAR{tireds}"
				}
			}
			return
		} else {
			bMotion_putloglev d * "tired but not enough to tell anyone yet"
		}
		return
	}

	if {$bMotionSettings(asleep) == $BMOTION_SLEEP(BEDTIME)} {
		bMotion_putloglev 3 * "considering bedtime -> sleep"
		if {[rand 10] > 3} {
			set bMotionSettings(asleep) $BMOTION_SLEEP(ASLEEP)
			putserv "AWAY :ZzZz"
			# go to sleep
			foreach chan $bMotionChannels {
				if [bMotion_is_active_enough $chan] {
					bMotion_putloglev 3 * "sending sleeping output to $chan"
					bMotionDoAction $chan "" "%VAR{go_sleeps}"
				}
			}
			putlog "bMotion: gone to sleep"
			set hour [bMotion_setting_get "wakeytime_hour"]
			set minute [bMotion_setting_get "wakeytime_minute"]
			set bMotionSettings(sleepy_nextchange) [bMotion_sleep_next_event "$hour:$minute"]
			return
		} else {
			bMotion_putloglev 1 * "not quite tired enough to actually go to sleep yet"
		}
		return
	}
	bMotion_putloglev d * "What th... bMotion_go_to_sleep called but I'm already asleep!"
}

proc bMotion_wake_up { } {
	global bMotionSettings BMOTION_SLEEP bMotionChannels
	bMotion_update_chanlist

	if {$bMotionSettings(asleep) == $BMOTION_SLEEP(ASLEEP)} {
		bMotion_putloglev 3 * "considering asleep -> awake"
		if {[rand 10] > 7} {
			putlog "bMotion: woke up!"
			set bMotionSettings(asleep) $BMOTION_SLEEP(AWAKE)
			putserv "AWAY"

			foreach chan $bMotionChannels {
				# don't check for active enough here, as we're waking everyone up
				# but do check we didn't speak last as that just looks dumb
				if {![bMotion_did_i_speak_last $chan]} {
					bMotion_putloglev 3 * "sending waking output to $chan"
					bMotionDoAction $chan "" "%VAR{wake_ups}"
				}
			}
			
			set hour [bMotion_setting_get "bedtime_hour"]
			set minute [bMotion_setting_get "bedtime_minute"]
			set bMotionSettings(sleepy_nextchange) [bMotion_sleep_next_event "$hour:$minute"]
			return
		} else {
			bMotion_putloglev d * "just a few more minutes in bed..."
		}
		return
	}
}

# check if the time is later than this
proc bMotion_later_than { hour minute } {
	set now [unixtime]
	set target [clock scan "$hour:$minute"]
	if {$target == ""} {
		return 0
	}
	if {$now > $target} {
		return 1
	}
	return 0
}



proc bMotion_check_tired2 { a b c d e } {
	global BMOTION_SLEEP bMotionSettings

	# check if we're past the time we should be changing
	if {[bMotion_setting_get "sleepy"] != 1} {
		return 0
	}

	set limit [bMotion_setting_get "sleepy_nextchange"]
	bMotion_putloglev 4 * "current time = [clock seconds], checking if we're past $limit"

	if {[clock seconds] >= $limit} {
		bMotion_putloglev d * "need to do a sleepy state change"

		set state [bMotion_setting_get "asleep"]
		if {$state == $BMOTION_SLEEP(AWAKE)} {
			bMotion_putloglev d * "maybe going to sleep"
			bMotion_go_to_sleep
			return
		}

		if {$state == $BMOTION_SLEEP(BEDTIME)} {
			bMotion_putloglev d * "maybe going to sleep"
			bMotion_go_to_sleep
			return
		}

		if {$state == $BMOTION_SLEEP(ASLEEP)} {
			bMotion_putloglev d * "maybe going to wake up"
			bMotion_wake_up
			return 
		}

		putlog "Whoops! Tried to do a sleepy state change but I'm not sure if I'm asleep or not :( ($state)"
		return
	}
}

proc bMotion_sleep_next_event { when } {
	global bMotionSettings

	set now [clock seconds]

	set ts [clock scan $when]
	if {$ts < $now} {
		# oh, add 24h
		incr ts 86400
	}
	bMotion_putloglev d * "sleepy: next state change at $ts = [clock format $ts]"
	return $ts
}

proc bMotion_did_i_speak_last { channel } {
	global bMotionCache
	
	catch {
		return $bMotionCache($channel,last)
	}

	#assume no
	return 0
}

# on start up, we should be awake and the next transition will be to sleep
if {[bMotion_setting_get "sleepy"] == 1} {
	set bMotionSettings(sleepy_nextchange) [bMotion_sleep_next_event "$bMotionSettings(bedtime_hour):$bMotionSettings(bedtime_minute)"]
}

proc bMotion_get_daytime { } {
	set hour [clock format [clock seconds] -format "%H"]

	if {$hour < 1} {
		return "evening"
	}

	if {$hour < 12} {
		return "morning"
	}

	if {$hour < 6} {
		return "afternoon"
	}

	return "evening"
}

bMotion_putloglev d * "bMotion: system module loaded"

