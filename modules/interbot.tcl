# bMotion - interbot stuff
#
# $Id$#
#

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

# Elect a new bot to speak for each channel
proc bMotion_interbot_next_elect { } {
  #send a message to all the bots on each of my channels
  # I pick a number and send it
  # This makes them all pick a number too and send that as a reply to all the other bots too
  # Each bot tracks the numbers, highest bot wins and speaks next

  global bMotionInfo bMotion_interbot_timer
  catch {
    foreach chan $bMotionInfo(randomChannels) {
      bMotion_interbot_next_elect_do $chan
    }
  }
  set bMotion_interbot_timer 1
  set delay [expr [rand 200] + 1700]
  bMotion_putloglev 2 * "bMotion: starting election timer"
  utimer $delay bMotion_interbot_next_elect
}

proc bMotion_interbot_next_elect_do { channel } {
  global bMotion_interbot_nextbot_score bMotion_interbot_nextbot_nick botnick bMotionInfo

  set myScore [rand 100]
  if {$bMotionInfo(away) == 1} {
    set myScore -2
  }
  set bMotion_interbot_nextbot_score($channel) $myScore
  set bMotion_interbot_nextbot_nick($channel) $botnick
  bMotion_putloglev 3 * "bMotion: assuming I'm the nextbot until I find another"
  catch {
    set bots [chanlist $channel]
    foreach bot $bots {
      #not me you idiot
      if [isbotnick $bot] { continue }
      bMotion_putloglev 4 * "bMotion: checking $bot for election in $channel"
      set handle [nick2hand $bot $channel]
      bMotion_putloglev 4 * "bMotion: checking $bot's handle; $handle"
      if {[matchattr $handle b&K $channel] && [islinked $handle]} {
        bMotion_putloglev 2 * "bMotion: sending elect_initial to $bot for $channel"
        putbot $handle "bmotion elect_initial $channel $myScore"
      }
      bMotion_putloglev 4 * "bMotion: checking $handle over" 
    }
  }
  bMotion_putloglev 3 * "bMotion: election over"
}

proc bMotion_interbot_catch { bot cmd args } {
  global bMotionInfo
  bMotion_putloglev 3 * "bMotion: incoming !$args!"
  set args [lindex $args 0]
  regexp {([^ ]+) (.+)} $args matches function params

  bMotion_putloglev 2 * "bMotion: got command $function ($params) from $bot"

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
  }

  return 0
}


proc bMotion_interbot_next_incoming { bot params } {
  #another bot is forcing an election
  global bMotion_interbot_nextbot_score bMotion_interbot_nextbot_nick botnick bMotionInfo

  bMotion_putloglev 1 * "bMotion: Incoming election from $bot"

  regexp "(\[#!\].+) (.+)" $params matches channel score
  if {$score > $bMotion_interbot_nextbot_score($channel)} {
    bMotion_putloglev 2 * "bMotion: $bot now has highest score on $channel"
    set bMotion_interbot_nextbot_score($channel) $score
    set bMotion_interbot_nextbot_nick($channel) $bot
  }
  
  set myScore [rand 100]
  if {$bMotionInfo(away) == 1} {
    set myScore -2
  }
  bMotion_putloglev 2 * "bMotion: My score is $myScore"

  if {$myScore > $bMotion_interbot_nextbot_score($channel)} {
    bMotion_putloglev 2 * "bMotion: Actually, I have highest score on $channel, sending out reply"
    set bMotion_interbot_nextbot_score($channel) $myScore
    set bMotion_interbot_nextbot_nick($channel) $botnick

    set bots [chanlist $channel]
    foreach bot $bots {
      #not me you idiot
      if [isbotnick $bot] { continue }
      set handle [nick2hand $bot $channel]
      if [matchattr $handle b&K $channel] {
        putbot $handle "bmotion elect_reply $channel $myScore"
      }
    }
  }
}

proc bMotion_interbot_next_incoming_reply { bot params } {
  #another bot is forcing an election
  global bMotion_interbot_nextbot_score bMotion_interbot_nextbot_nick 

  bMotion_putloglev 1 * "bMotion: Incoming election reply from $bot"

  regexp "(\[#!\].+) (.+)" $params matches channel score
  if {$score > $bMotion_interbot_nextbot_score($channel)} {
    bMotion_putloglev 2 * "bMotion: $bot now has highest score on $channel"
    set bMotion_interbot_nextbot_score($channel) $score
    set bMotion_interbot_nextbot_nick($channel) $bot
  }
}

proc bMotionSendSayChan { channel  text thisBot} {
  #global bMotionAvailableBots
  #global bMotionCache

  #set thisBot $bMotionCache(remoteBot)

  #replace all ¬ with %
  set text [bMotionInsertString $text "¬" "%"]
  bMotion_putloglev 1 * "bMotion: pushing command say ($channel $text) to $thisBot"
  if [islinked $thisBot] {
    putbot $thisBot "bmotion say $channel $text"
    return $thisBot
  } else {
    putlog "bMotion: ALERT! Trying to talk to bot $thisBot, but it isn't linked"
    return ""
  }
}

proc bMotionCatchSayChan { bot params } {
  global bMotionInfo

  #bMotion_putloglev d * "bMotion: got command $function ($params) from $bot"

  regexp {(\[#!\][^ ]+) (.+)} $params matches channel txt
  global bMotionQueueTimer
  if {$bMotionQueueTimer == 0} {
    set bMotionQueueTimer 1
    utimer 4 bMotionProcessQueue
  }
  if {$bMotionInfo(silence) == 1} {
    set bMotionInfo(silence) 2
  }
  bMotionDoAction $channel $bot $txt
  bMotion_putloglev 1 * "bMotion: done say command from $bot"
  if {$bMotionInfo(silence) == 2} {
    set bMotionInfo(silence) 1
  }
  return 0
}

# Check if we're due to talk next on the channel
# if yes, then force an election for that channel immediately afterwards
proc bMotion_interbot_me_next { channel } {
  global bMotion_interbot_nextbot_nick bMotion_interbot_nextbot_score botnick

  set channel [string tolower $channel]
  set me 0 
  ## /|\  KIS hack
  catch {
    if {$bMotion_interbot_nextbot_score($channel) < 0} {
      bMotion_putloglev 4 * "bMotion: nextbot_score is <0, I'm not answering"
      return 0
    }

    if {$bMotion_interbot_nextbot_nick($channel) == $botnick} {
      bMotion_putloglev 4 * "bMotion: nextbot_nick is me"
      bMotion_interbot_next_elect_do $channel
      set me 1 
      ## /|\ KIS hack
      return 1
    }
  }
  bMotion_putloglev 4 * "bMotion: nextbot_nick is not me" 
  #if it's noone, the winning bot will force an election anyway
  return $me 
  #return 0
  ## /|\ KIS hack, was 0, hacked to $me to force single botnet workings
}

# send a fake event
proc bMotion_interbot_fake_event { botnick channel fromnick line } {
  if {[matchattr $botnick b&K $channel] && [islinked $botnick]} {
    putbot $botnick "bmotion fake_event $channel $fromnick $line"
    return 1
  }
}

# catch the fake event
proc bMotion_interbot_fake_catch { bot params } {
  bMotion_putloglev 1 * "Incoming fake event from $bot: $params"
  regexp {([^ ]+) ([^ ]+) (.+)} $params matches channel fromnick line
  #proc bMotion_event_main {nick host handle channel text}
  putlog $line
  bMotion_event_main $fromnick "fake@fake.com" $fromnick $channel $line
  return 1
}

#call an election when we start/rehash
foreach chan $bMotionInfo(randomChannels) {
  set bMotion_interbot_nextbot_score($chan) "-1"
  set bMotion_interbot_nextbot_nick($chan) ""
}
bMotion_interbot_next_elect

#interbot stuff
bind bot I "bmotion" bMotion_interbot_catch

bMotion_putloglev d * "bMotion: interbot module loaded"
