# bMotion - event supporting functions
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

proc finishdildo {} {
  global got mood dildoPlays

  set style $got(dildo,style)

  if {$style == "flute"} {
    global dildoFluteFinishes
    cum $got(dildo,channel) $got(dildo,nick)
    bMotionDoAction $got(dildo,channel) $got(dildo,nick) [pickRandom $dildoFluteFinishes]
    set got(dildo,nick) ""
    set got(dildo,count) 0
    incr mood(happy) 1
    incr mood(horny) -2
    return 0
  }

  if {$style == "f_swap"} {
    global dildoFemaleFemaleSwap
    bMotionDoAction $got(dildo,channel) $got(dildo,dildo) [pickRandom $dildoFemaleFemaleSwap]
    set got(dildo,style) "normal"
    utimer 70 finishdildo
    return 0
  }
  
  if {$style == "m_swap"} {
    global dildoMaleMaleSwap
    bMotionDoAction $got(dildo,channel) $got(dildo,dildo) [pickRandom $dildoMaleMaleSwap]
    set got(dildo,style) "normal"
    utimer 70 finishdildo
    return 0
  }

  global dildoFinishes
  cum $got(dildo,channel) $got(dildo,nick)
  bMotionDoAction $got(dildo,channel) $got(dildo,dildo) [pickRandom $dildoFinishes] $got(dildo,nick)
  set got(dildo,nick) ""
  set got(dildo,count) 0
  incr mood(happy) 1
  incr mood(horny) -2
}

## BEGIN lol function (TODO: rename this and calls to it)
proc lol {nick host handle channel text} {
  #ignore the J flag users
  if [matchattr $handle J] {
    return 0
  }

  global botnick mood lols bMotionCache
  if {$nick == $botnick} {return 0}

  if {![bMotionIsFriend $nick]} { return 0 }

  incr bMotionCache(LOLcount)
  if {[string toupper $text] == $text} { incr bMotionCache(LOLcount) }
  if {$bMotionCache(LOLcount) > 3} {  
    if {$mood(happy) < -10} {
      incr mood(happy)
      return 0
    }
    if {[rand 10] > 6} {
      set response [pickRandom $lols]      
      bMotionDoAction $channel $nick $response
      set bMotionCache(LOLcount) 0
    }
    checkmood "" ""
  }
}
## END

proc cum {channel nick} {
  global bMotionInfo
  global mood
  if {![pastWatershedCheck $nick]} { return 0 }  
  if {![bMotionIsFriend $nick]} { 
    bMotionDoAction $channel $nick "%VAR{blehs} I can't cum thinking about someone I don't like"
    return 0
  }
  if {$bMotionInfo(gender) == "male"} {
    bMotionDoAction $channel $nick "/ejaculates over %%"
    incr mood(horny) -3
    incr mood(happy) 2
    return 0
  }
  bMotionDoAction $channel $nick "/makes herself cum thinking about %%"
  incr mood(horny) -3
  incr mood(happy) 2
  return 0
}

proc frightened {nick channel} {
  global frightens unsmiles mood
  bMotionDoAction $channel $nick "[pickRandom $frightens] [pickRandom $unsmiles]"
  incr mood(lonely) -1
  incr mood(happy) -1
}

proc bMotionMakeItSo {nick channel} {
  global makeItSos
  bMotionDoAction $channel $nick [pickRandom $makeItSos]
  global bMotionCache
  set bMotionCache(lastDoneFor) $nick
}

proc checkPokemon {which channel} {
  global bMotionInfo
  if {$bMotionInfo(pokemon) != [string tolower $which]} {
    bMotionDoAction $channel $which "/morphs into %%!"
    set bMotionInfo(pokemon) [string tolower $which]
  }
}

proc bMotionYesNo {channel} {
  global yeses nos
  set yesnos [concat $yeses $nos]
  bMotionDoAction $channel "" [pickRandom $yesnos]
  return 0
}

proc bMotionBlessYou {channel nick} {
  global bMotionInfo
  global blessyous
  if {![bMotionIsFriend $nick]} { return 0 }
  if {[rand 2] && ($bMotionInfo(balefire) == 1)} {
    bMotionDoAction $channel $nick [pickRandom $blessyous]
    bMotionGetUnLonely
  }
}

proc bMotionRandomTime {channel nick} {
	set hour [expr [rand 11] + 1]
	set min [rand 59]
	if [rand 2] {
	  set ampm "am"
	} else {
	  set ampm "pm"
	  }

	if {$min < 30} {
	  set timestr "$min past $hour"
	  }

	if {$min == 30} {
	  set timestr "half-past $hour"
	  }

	if {$min > 30} {
	  set min [expr 60 - $min]
	  set timestr "$min to $hour"
	  }

  if {$min == 0} {
    set timestr "$hour"
  }

	bMotionDoAction $channel $nick "%%: about $timestr $ampm"
	return 0
}

proc bMotionRandomQuestion {channel} {
  global sillyThings

  set silly1 [pickRandom $sillyThings]
  set silly2 [pickRandom $sillyThings]

  bMotionDoAction $channel "" "$silly1 or $silly2?"
  return 0
}

proc bMotionEndTeamRocket {} {
  global bMotionCache
  set bMotionCache(teamRocket) ""
}    

bMotion_putloglev d * "bMotion: event support module loaded"