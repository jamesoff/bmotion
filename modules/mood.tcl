# bMotion - Mood handling
#
# $Id$
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

#Init variables
set mood(happy) 0
set mood(horny) 0
set mood(lonely) 0
set mood(electricity) 2
set mood(stoned) 0

set moodtarget(happy) 0
set moodtarget(horny) 0
set moodtarget(lonely) 5
set moodtarget(electricity) 2
set moodtarget(stoned) 0


## MOOD ROUTINES _________________________________________________________________________________
proc bMotionGetHappy {} {
  global mood
  incr mood(happy) 1
  checkmood "" ""
}

proc bMotionGetSad {} {
  global mood
  incr mood(happy) -1
  checkmood "" ""
}

proc bMotionGetHorny {} {
  global mood
  incr mood(horny) 1
  checkmood "" ""
}

proc bMotionGetUnHorny {} {
  global mood
  incr mood(horny) -1
  checkmood "" ""
}

proc bMotionGetLonely {} {
  global mood
  incr mood(lonely) 1
  checkmood "" ""
}

proc bMotionGetUnLonely {} {
  global mood
  incr mood(lonely) -1
  checkmood "" ""
}

## Checkmood: checks the moods are within limits
proc checkmood {nick channel} {
  global mood
  foreach r {happy horny lonely electricity stoned} {
    if {$r < -30} { 
      set mood($r) -30 
      bMotion_putloglev d * "bMotion: Mood($r) went OOB, resetting to -30"
    }
    if {$mood($r) > 30} { 
      bMotion_putloglev d * "bMotion: Mood($r) went OOB, resetting to 30"
      set mood($r) 30 
    }
  }
  if {$nick == ""} {return 0}

	if {($mood(happy) > 10) && ($mood(lonely) > 5) && ($mood(horny) > 5)} {
		mee $channel "replicates some tissues"
		mee $channel "locks [getPronoun] in the bathroom"
		set mood(horny) [expr $mood(horny) - 10]
		set mood(lonely) [expr $mood(lonely) -3]
	}
}


## Driftmood: Drifts all moods towards 0
proc driftmood {} {
  global bMotionCache
  set bMotionCache(lastHows) ""
  set driftSummary ""
  global mood mooddrifttimer moodtarget
  foreach r {happy horny lonely electricity stoned} {
    set drift 0
    set driftString ""
    if {$mood($r) > $moodtarget($r)} {
      set drift -1
      set driftString "$moodtarget($r)<$mood($r)"
    }
    if {$mood($r) < $moodtarget($r)} {
      set drift 2
      set driftString "$mood($r)>$moodtarget($r)"
    }
    if {$drift != 0} {
      set mood($r) [expr $mood($r) + $drift]
      set driftSummary "$driftSummary $r ($driftString) "
    }
  }
  if {$driftSummary != ""} {
    bMotion_putloglev d * "bMotion: driftMood $driftSummary"
  }
  checkmood "" ""
  set mooddrifttimer 1

  #now also drift all channels towards 0
  global bMotionInfo
  foreach chan $bMotionInfo(randomChannels) {
    set chanMood $bMotionCache($chan,mood)
    if {$chanMood > 0} {
      incr chanMood -1
    }
    if {$chanMood < 0} {
      incr chanMood
    }
    set bMotionCache($chan,mood) $chanMood
  }

  timer 10 driftmood
  return 0
}


## moodTimerStart: Used to start the mood drift timer when the script initialises
## and other timers now, too
proc moodTimerStart {} {
  global mooddrifttimer
	if  {![info exists mooddrifttimer]} {
		timer 10 driftmood
    utimer 5 loldec
#    utimer 90 smileyhandler
    timer [expr [rand 30] + 3] doRandomStuff
		set mooddrifttimer 1
	}
}


## moodHander: DCC .mood
proc moodhandler {handle idx arg} {
  global mood
  putidx $idx "My current mood is $mood(happy) $mood(horny) $mood(lonely) $mood(electricity) $mood(stoned): happy horny lonely electricity stoned"
  if {$arg != ""} {
    if {$arg == "drift"} {
      driftmood
      return 0
    }
    set moodtype [lindex $arg 0]
    set moodsetting [lindex $arg 1]
    set mood($moodtype) $moodsetting
    putlog "bMotion: Mood($moodtype) changed to $moodsetting by $handle"
  }
  checkmood "" ""
}


## pubm_moodHandler: !mood
proc pubm_moodhandler {nick host handle channel text} {
  global mood botnick
  set text [string trim $text]
  if [regexp -nocase "^${botnick}$" $text] {
    set ming "Mood: "
    foreach r {happy horny lonely electricity stoned} {
      append ming " $r=$mood($r) "
    }
    global bMotionCache
    append ming " chanmood=[makeSmiley $bMotionCache($channel,mood)]"
    bMotionDoAction $channel "" $ming
    return 0
  }

  if [regexp -nocase "^$botnick (.+)" $text args] {
    if {[matchattr $handle m]} {
      if {$args == "drift"} {
        driftmood
        return 0
      }
      set moodtype [lindex $args 1]
      set moodsetting [lindex $args 2]
			if {[catch {expr $moodsetting}]} {
			  putserv "PRIVMSG $nick :Fewl, that's not right."
			  return 0
		  }
      set mood($moodtype) $moodsetting
      putlog "bMotion: Mood($moodtype) changed to $moodsetting by $handle"
      mee $channel "undergoes mood swing"
      return 0
    } else {
      bMotionDoAction $channel "" "No."
      putlog "bMotion: $nick tried mood $args on $channel and failed."
      return 0
    }
  }
  checkmood "" ""
}

## pubm_moodHandler: !mood
proc pubm_moodhandler {nick host handle channel text} {
  if {![matchattr $handle n]} {
    return 0
  }


  global mood botnick
  set text [string trim $text]
  if [regexp -nocase "^${botnick}$" $text] {
    set ming "Mood: "
    foreach r {happy horny lonely electricity stoned} {
      append ming " $r=$mood($r) "
    }
    global bMotionCache
    append ming " chanmood=[makeSmiley $bMotionCache($channel,mood)]"
    bMotionDoAction $channel "" $ming
    return 0
  }

  if [regexp -nocase "^$botnick (.+)" $text args] {
    if {[matchattr $handle m]} {
      if {$args == "drift"} {
        driftmood
        return 0
      }
      set moodtype [lindex $args 1]
      set moodsetting [lindex $args 2]
			if {[catch {expr $moodsetting}]} {
			  putserv "PRIVMSG $nick :Fewl, that's not right."
			  return 0
		  }
      set mood($moodtype) $moodsetting
      putlog "bMotion: Mood($moodtype) changed to $moodsetting by $handle"
      mee $channel "undergoes mood swing"
      return 0
    } else {
      bMotionDoAction $channel "" "No."
      putlog "bMotion: $nick tried mood $args on $channel and failed."
      return 0
    }
  }
  checkmood "" ""
}

#add some default moods

set mood(happy) 0
set moodtarget(happy) 0
#bMotion_mood_add "happy" -30 30 0 1 2

set mood(horny) 0
set moodtarget(horny) 0
#bMotion_mood_add "horny" -30 30 0 1 2

set mood(lonely) 0
set moodtarget(lonely) 5
#bMotion_mood_add "lonely" -30 30 5 1 2


set mood(electricity) 2
set moodtarget(electricity) 2
#bMotion_mood_add "electricity" 0 2 2 1 2

set mood(stoned) 0
set moodtarget(stoned) 0
#bMotion_mood_add "stoned" 0 30 0 1 2

bMotion_putloglev d * "bMotion: mood module loaded"
