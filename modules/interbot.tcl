# bMotion - interbot stuff
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

# allow people to turn off the interbot stuff if they don't want it
# these values should be set in the settings file, but we'll define
# some defaults here

if {![info exists bMotion_interbot_enable]} {
	set bMotion_interbot_enable 1
}

# Elect a new bot to speak for each channel
proc bMotion_interbot_next_elect { } {
	#send a message to all the bots on each of my channels
	# I pick a number and send it
	# This makes them all pick a number too and send that as a reply to all the other bots too
	# Each bot tracks the numbers, highest bot wins and speaks next

	global bMotionInfo bMotion_interbot_timer bMotionChannels
	global bMotion_interbot_enable

	if {!$bMotion_interbot_enable} {
		return
	}

	catch {
		foreach chan $bMotionChannels {
			bMotion_interbot_next_elect_do $chan
		}
	}
	set bMotion_interbot_timer 1
	set delay [expr [rand 200] + 1700]
	bMotion_putloglev 2 * "interbot: starting election timer"
	utimer $delay bMotion_interbot_next_elect
}

proc bMotion_interbot_next_elect_do { channel } {
	global bMotion_interbot_nextbot_score bMotion_interbot_nextbot_nick botnick bMotionInfo
	global bMotion_interbot_pending_channels bMotionGlobal

	bMotion_putloglev 2 * "interbot: running election on $channel"

	# look to see if this channel is recorded as having a pending election
	# if it is, remove it. this is slightly a race condition but it's harmless
	set pos [lsearch $bMotion_interbot_pending_channels [string tolower $channel]]
	if {$pos > -1 } {
		set bMotion_interbot_pending_channels [lreplace $bMotion_interbot_pending_channels $pos $pos]
	}

	set myScore [rand 100]
	if {$bMotionInfo(away) == 1} {
		set myScore -2
	}
	if {$bMotionGlobal == 0} {
		set myScore -2
	}

	set bMotion_interbot_nextbot_score($channel) $myScore
	set bMotion_interbot_nextbot_nick($channel) $botnick
	bMotion_putloglev 3 * "interbot: assuming I'm the nextbot until I find another"
	catch {
		set bots [chanlist $channel]
		foreach bot $bots {
			#not me you idiot
			if [isbotnick $bot] { continue }
			bMotion_putloglev 4 * "interbot: checking $bot for election in $channel"
			set handle [nick2hand $bot $channel]
			bMotion_putloglev 4 * "interbot: checking $bot's handle; $handle"
			if {[matchattr $handle b $channel] && [islinked $handle]} {
				bMotion_putloglev 2 * "interbot: sending elect_initial to $bot for $channel"
				putbot $handle "bmotion elect_initial $channel $myScore"
			}
			bMotion_putloglev 4 * "interbot: checking $handle over" 
		}
	}
	bMotion_putloglev 3 * "interbot: election over for $channel"
}

proc bMotion_interbot_catch { bot cmd args } {
	global bMotionInfo
	bMotion_putloglev 3 * "interbot: incoming !$args!"
	set args [lindex $args 0]
	if [regexp {([^ ]+)( (.+))?} $args matches function 1 params] {

		bMotion_putloglev 2 * "interbot: got command $function ($params) from $bot"

		switch -exact $function {
			"say" {
				# bmotion say <channel> <text>
				bMotionCatchSayChan $bot $params
			}

			"elect_initial" {
				bMotion_interbot_next_incoming $bot $params
			}

			"elect_reply" {
				bMotion_interbot_next_incoming_reply $bot $params
			}

			"fake_event" {
				bMotion_interbot_fake_catch $bot $params
			}

			"HAY" {
				bMotion_interbot_hay $bot $params
			}

			"SUP" {
				bMotion_interbot_sup $bot $params
			}

			"BYE" {
				bMotion_interbot_bye $bot
			}
		}
	} else {
		putlog "bMotion: ERROR: received unparsable interbot command from $bot: $cmd $args"
	}

	return 0
}


proc bMotion_interbot_next_incoming { bot params } {
	#another bot is forcing an election
	global bMotion_interbot_nextbot_score bMotion_interbot_nextbot_nick botnick bMotionInfo
	global BMOTION_SLEEP bMotionSettings bMotion_interbot_enable

	if {![info exists bMotion_interbot_enable]} {
		return
	}

	bMotion_putloglev 1 * "interbot: Incoming election from $bot"

	regexp "(\[#!\].+) (.+)" $params matches channel score
	catch {
		if {$score > $bMotion_interbot_nextbot_score($channel)} {
			bMotion_putloglev 2 * "interbot: $bot now has highest score on $channel"
			set bMotion_interbot_nextbot_score($channel) $score
			set bMotion_interbot_nextbot_nick($channel) $bot
		}
	}
	
	set myScore [rand 100]
	if {$bMotionInfo(away) == 1} {
		set myScore -2
	}
	if {$bMotionSettings(asleep) == $BMOTION_SLEEP(ASLEEP)} {
		set myScore -2
	}

	bMotion_putloglev 2 * "interbot: My score is $myScore"

	if {(![info exists bMotion_interbot_nextbot_score($channel)]) || ($myScore > $bMotion_interbot_nextbot_score($channel))} {
		bMotion_putloglev 2 * "interbot: Actually, I have highest score on $channel, sending out reply"
		set bMotion_interbot_nextbot_score($channel) $myScore
		set bMotion_interbot_nextbot_nick($channel) $botnick

		set bots [chanlist $channel]
		foreach bot $bots {
			#not me you idiot
			if [isbotnick $bot] { continue }
			set handle [nick2hand $bot $channel]
			if [matchattr $handle b $channel] {
				putbot $handle "bmotion elect_reply $channel $myScore"
			}
		}
	}
}

proc bMotion_interbot_next_incoming_reply { bot params } {
	#another bot is forcing an election
	global bMotion_interbot_nextbot_score bMotion_interbot_nextbot_nick 

	bMotion_putloglev 1 * "interbot: Incoming election reply from $bot"

	regexp "(\[#!\].+) (.+)" $params matches channel score
	if {$score > $bMotion_interbot_nextbot_score($channel)} {
		bMotion_putloglev 2 * "interbot: $bot now has highest score on $channel"
		set bMotion_interbot_nextbot_score($channel) $score
		set bMotion_interbot_nextbot_nick($channel) $bot
	}
}

proc bMotionSendSayChan { channel text thisBot} {
	#replace all ¬ with %
	global bMotion_interbot_enable

	if {!$bMotion_interbot_enable} {
		return ""
	}

	set text [bMotionInsertString $text "¬" "%"]
	bMotion_putloglev 1 * "interbot: pushing command say ($channel $text) to $thisBot"
	if [islinked $thisBot] {
		putbot $thisBot "bmotion say $channel :$text"
		return $thisBot
	} else {
		putlog "interbot: ALERT! Trying to talk to bot $thisBot, but it isn't linked"
		return ""
	}
}

proc bMotionCatchSayChan { bot params } {
	global bMotionInfo
	global bMotionQueueTimer

	bMotion_putloglev 4 * "interbot: bMotionCatchSayChan $bot $params"

	if [regexp {([#!][^ ]+) :(.+)} $params matches channel txt] {
	
		if {$bMotionInfo(silence) == 1} {
			set bMotionInfo(silence) 2
		}
		
		#check we haven't been sent broken text to output by %bot
		regsub "^\[0-9\]+,(.+)" $txt {\1} txt

		bMotionDoAction $channel $bot $txt "" 0 1
		bMotion_putloglev 1 * "interbot: done say command from $bot"
		if {$bMotionInfo(silence) == 2} {
			set bMotionInfo(silence) 1
		}
	} else {
		putlog "bMotion ALERT! Error unwrapping command !say $params! from $bot"
	}
	return 0
}

# Check if we're due to talk next on the channel
# if yes, then force an election for that channel immediately afterwards
proc bMotion_interbot_me_next { channel } {
	global bMotion_interbot_nextbot_nick bMotion_interbot_nextbot_score botnick
	global bMotion_interbot_enable bMotion_interbot_pending_channels

	set channel [string tolower $channel]

	if {!$bMotion_interbot_enable} {
		# if interbot stuff is turned off, we'll have to assume we should respond
		# else we'd never say anything...
		return 1
	}

	bMotion_putloglev 2 * "checking interbot_me_next for $channel"

	if {[bMotion_setting_get "bitlbee"] == "1"} {
		return 1
	}

	#let's look to see if we know any other bots on the botnet
	if {[llength [bMotion_interbot_otherbots $channel]] == 0} {
		bMotion_putloglev 4 * "interbot: no other bots, returning 1"
		return 1
	}

	set me 0 
	catch {
		if {$bMotion_interbot_nextbot_score($channel) < 0} {
			bMotion_putloglev 4 * "interbot: nextbot_score is <0, I'm not answering"
		}

		if {$bMotion_interbot_nextbot_nick($channel) == $botnick} {
			bMotion_putloglev 4 * "interbot: nextbot_nick is me; calling election and returning 1"
			if {[lsearch $bMotion_interbot_pending_channels [string tolower $channel]] == -1} {
				lappend bMotion_interbot_pending_channels [string tolower $channel]
				utimer 3 " bMotion_interbot_next_elect_do $channel "
			} else {
				bMotion_putloglev 4 * "interbot: not calling another election as one is pending for this channel"
			}
			set me 1 
		}
	}
	#
	#if it's noone, the winning bot will force an election anyway
	bMotion_putloglev 2 * "interbot: returning $me for $channel"
	return $me 
}

# send a fake event
proc bMotion_interbot_fake_event { botnick channel fromnick line } {
	if {[matchattr $botnick b $channel] && [islinked $botnick]} {
		putbot $botnick "bmotion fake_event $channel $fromnick $line"

		return 1
	}
}

# catch the fake event
proc bMotion_interbot_fake_catch { bot params } {
	bMotion_putloglev 1 * "Incoming fake event from $bot: $params"
	regexp {([^ ]+) ([^ ]+) (.+)} $params matches channel fromnick line
	#proc bMotion_event_main {nick host handle channel text}
	#putlog $line
	bMotion_event_main $fromnick "fake@fake.com" $fromnick $channel $line
	return 1
}

#call an election when we start/rehash
foreach chan $bMotionChannels {
	set bMotion_interbot_nextbot_score($chan) "-1"
	set bMotion_interbot_nextbot_nick($chan) ""
}
bMotion_interbot_next_elect

# bMotion_interbot_link
#
# callback for a bot linking to the botnet
proc bMotion_interbot_link { botname via } {
	global bMotionChannels bMotionGlobal
	bMotion_update_chanlist
	if {!$bMotionGlobal} {
		return
	}

	#let's announce we're a bmotion bot
	putbot $botname "bmotion SUP $bMotionChannels"
}

# bMotion_interbot_hay
#
# Catches a HAY from another bot, replies with a SUP
proc bMotion_interbot_hay { bot channels } {
	#we've met another bmotion bot, we need to tell it what channels we're on
	global bMotion_interbot_otherbots network bMotionChannels bMotion_interbot_enable bMotionGlobal

	if {!$bMotion_interbot_enable} {
		return
	}

	if {!$bMotionGlobal} {
		return
	}

	bMotion_update_chanlist
	if [regexp -nocase {(.+) network:(.+)} $channels matches chans nw] {
		if {[string tolower $nw] != [string tolower $network]} {
			bMotion_putloglev 2 * "Ignoring HAY from bot on wrong network (me: $network; $bot: $nw)"
			return
		}
		set channels $chans
	}
	set bMotion_interbot_otherbots($bot) $channels
	bMotion_putloglev 1 * "interbot: Met bMotion bot $bot on channels $channels"
	putbot $bot "bmotion SUP $bMotionChannels"
}

# bMotion_interbot_sup
#
# Catches a SUP (reply to my HAY)
proc bMotion_interbot_sup { bot channels } {
	#we've met another bmotion bot
	global bMotion_interbot_otherbots bMotion_interbot_enable

	if {!$bMotion_interbot_enable} {
		return
	}

	set bMotion_interbot_otherbots($bot) $channels
	bMotion_putloglev 1 * "interbot: bMotion bot $bot on channels $channels"
}

proc bMotion_interbot_bye { bot } {
	# sent by a bot when bMotion's disabled
	global bMotion_interbot_otherbots

	bMotion_putloglev d * "interbot: erasing $bot from history"

	array unset bMotion_interbot_otherbots $bot
}


proc bMotion_interbot_send_bye { } {
	global bMotion_interbot_enable
	
	if {!$bMotion_interbot_enable} {
		return
	}
	bMotion_putloglev d * "interbot: telling all other bots to forget me"
	putallbots "bmotion BYE"
}

array set bMotion_interbot_otherbots {}

# bMotion_interbot_resync
#
# Broadcasts a HAY to see who's around
proc bMotion_interbot_resync { } {
	#let's find out who's on the botnet
	global bMotion_interbot_otherbots network bMotionChannels bMotion_interbot_enable

	utimer [expr [rand 900] + 300] bMotion_interbot_resync

	if {$bMotion_interbot_enable != 1} {
		return
	}

	bMotion_update_chanlist
	unset bMotion_interbot_otherbots
	array set bMotion_interbot_otherbots {}

	putloglev d * "interbot: Resyncing with botnet for bMotion bots"
	putallbots "bmotion HAY $bMotionChannels ($network)"
}

# bMotion_interbot_otherbots
#
# Returns other bots we know on this channel
proc bMotion_interbot_otherbots { channel } {
	global bMotion_interbot_otherbots

	set otherbots [list]

	foreach bot [array names bMotion_interbot_otherbots] {
		if {[lsearch $bMotion_interbot_otherbots($bot) $channel] > -1} {
			lappend otherbots $bot
		}
	}
	return $otherbots
}


# bMotion_interbot_is_bmotion
#
# checks if another bot is a bmotion bot
proc bMotion_interbot_is_bmotion { handle } {
	global bMotion_interbot_otherbots

	if [info exists bMotion_interbot_otherbots($handle)] {
		return 1
	}
	return 0
}


# set up our binds
bind bot - "bmotion" bMotion_interbot_catch
bind link - * bMotion_interbot_link

utimer [expr [rand 900] + 300] bMotion_interbot_resync

# this list holds names of channels we've got timers to elect on
# stops multiple timers being set for each channel
set bMotion_interbot_pending_channels [list]

bMotion_putloglev d * "interbot: interbot module loaded"
