# bMotion - System function
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

# this function cleans the CVS string to get the version out of it
proc bMotionCleanCVSString { cvs } {
  if [regexp {\$[I][d].+?,(.+) Exp \$} $cvs matches core] {
    return $core
  }
  return $cvs
}
set cvsinfo [bMotionCleanCVSString {$Id$}]
set randomsinfo [bMotionCleanCVSString $randomsVersion]

#Set up the binds
bind msg m bmotion msg_bmotioncommand
bind join - *!*@* bMotion_event_onjoin
bind mode - * bMotion_event_mode
#bind pub - "!sites" interactive:lamersites
bind pub - !bmadmin bMotionAdminHandler
bind pubm - * bMotion_event_main
bind dcc m mood moodhandler
bind dcc m bmotion* dcc_bmotioncommand
bind dcc m bmadmin* bMotion_dcc_command
bind dcc m bmhelp bMotion_dcc_help
bind sign - *!*@* bMotion_event_onquit
bind nick - * bMotion_event_nick

if {$bMotionSettings(needI) == 1} {
  ## binds for +I mode
  bind part I *!*@* bMotion_event_onpart
  bind pub I "!mood" pubm_moodhandler
  bind ctcp I ACTION bMotion_event_action
  bind pub I "!bminfo" bMotionInfo
} else {
  ## everyone can do stuff
  bind part - *!*@* bMotion_event_onpart
  bind pub - "!mood" pubm_moodhandler
  bind ctcp - ACTION bMotion_event_action
  bind pub - "!bminfo" bMotionInfo
}

foreach chan $bMotionInfo(randomChannels) {
  set bMotionLastEvent($chan) [clock seconds]
  set bMotionInfo(adminSilence,$chan) 0
  #set to 1 when the bot says something, and 0 when someone else says something
  #used to make the bot a bit more intelligent (perhaps) at conversations
  set bMotionCache($chan,last) 0
  #channel mood tracker
  set bMotionCache($chan,mood) 0
}


proc bMotionInfo {nick host handle channel text} {  
  global bMotionInfo botnicks bMotionSettings cvsinfo randomsinfo botnick
  if {![regexp -nocase $botnick $text]} { return 0 }
  set timezone [clock format [clock seconds] -format "%Z"]  
  set status "I am running bMotion under TCL [info patchlevel]: botGender $bMotionInfo(gender)/$bMotionInfo(orientation) : balefire $bMotionInfo(balefire) : pokemon $bMotionInfo(pokemon) : timezone $timezone : randomStuff $bMotionInfo(minRandomDelay), $bMotionInfo(maxRandomDelay), $bMotionInfo(maxIdleGap) : botnicks $botnicks : melMode $bMotionSettings(melMode) : needI $bMotionSettings(needI) : cvs $cvsinfo : randoms $randomsinfo"
  if {$bMotionInfo(silence)} { set status "$status : silent (yes)" }
  append status " : www.bmotion.net"
  putchan $channel $status
}

proc doRandomStuff {} {
  global bMotionInfo mood stonedRandomStuff bMotionInfo
  global bMotionLastEvent
  set timeNow [clock seconds]
  set saidChannels ""
  set silentChannels ""

  #do this first now
  set upperLimit [expr $bMotionInfo(maxRandomDelay) - $bMotionInfo(minRandomDelay)]
  set temp [expr [rand $upperLimit] + $bMotionInfo(minRandomDelay)]
  timer $temp doRandomStuff
  bMotion_putloglev d * "bMotion: randomStuff next ($temp minutes)";


  #not away

  #find the most recent event
  set mostRecent 0
  set line "comparing idle times: "
  foreach channel $bMotionInfo(randomChannels) {
    append line "$channel=$bMotionLastEvent($channel) "
    if {$bMotionLastEvent($channel) > $mostRecent} {
      set mostRecent $bMotionLastEvent($channel)
    }
  }
  bMotion_putloglev 1 * "bMotion: most recent: $mostRecent .. timenow $timeNow .. gap [expr $bMotionInfo(maxIdleGap) * 10]"
  
  set idleEnough 0

  if {($timeNow - $mostRecent) > ([expr $bMotionInfo(maxIdleGap) * 10])} {
    set idleEnough 1
  }

  if {$idleEnough} {
    if {$bMotionInfo(away) == 1} {
      #away, don't do anything
      return 0
    }

    #channel is quite idle
    putlog "bMotion: All channels are idle, going away"
    if {[rand 4] == 0} {
      bMotionSetRandomAway
      return 0
    }
  }

  #not idle
  
  #set back if away
  if {$bMotionInfo(away) == 1} {
    bMotionSetRandomBack
  }

  #we didn't set ourselves away, let's do something random
  foreach channel $bMotionInfo(randomChannels) {
    if {($timeNow - $bMotionLastEvent($channel)) < ($bMotionInfo(maxIdleGap) * 60)} {
      set saidChannels "$saidChannels $channel"
      bMotionSaySomethingRandom $channel
    } else {
      set silentChannels "$silentChannels $channel"
    }
  }
  bMotion_putloglev d * "bMotion: randomStuff said ($saidChannels) silent ($silentChannels)"
}

proc bMotionSaySomethingRandom {channel} {
  global randomStuff stonedRandomStuff randomStuffMale randomStuffFemale mood bMotionInfo
  
  set myRandomStuff $randomStuff

  if {$mood(stoned) > 9} {
    set myRandomStuff [concat $myRandomStuff $stonedRandomStuff]
  }
  if {$bMotionInfo(gender) == "male"} {
    set myRandomStuff [concat $myRandomStuff $randomStuffMale]
  } else {
    set myRandomStuff [concat $myRandomStuff $randomStuffFemale]
  }

  if [rand 2] {
    bMotionDoAction $channel "" [pickRandom $myRandomStuff]
  }

  return 0
}

proc bMotionSetRandomAway {} {
  #set myself away with a random message
  global randomAways bMotionInfo

  set awayReason [pickRandom $randomAways]
  foreach channel $bMotionInfo(randomChannels) {
    bMotionDoAction $channel $awayReason "/is away: %%"
  }
  putserv "AWAY :$awayReason"
  set bMotionInfo(away) 1
  set bMotionInfo(silence) 1
  bMotion_putloglev d * "bMotion: Set myself away: $awayReason"
  bMotion_putloglev d * "bMotion: Going silent"
}

proc bMotionSetRandomBack {} {
  #set myself back
  global bMotionInfo

  set bMotionInfo(away) 0
  set bMotionInfo(silence) 0
  foreach channel $bMotionInfo(randomChannels) {
    bMotionDoAction $channel "" "/is back"
  }
  putserv "AWAY"

  #elect cos we're available now
  bMotion_interbot_next_elect

  return 0
}

## bMotionTalkingToMe ########################################################
proc bMotionTalkingToMe { text } {
  global botnicks
  if [regexp -nocase "(^${botnicks}:?|${botnicks}\\?$)" $text] {
    return 1
  }
  return 0
}

proc bMotionSilence {nick host channel} {
  # We've been told to shut up :(
  # Let's be silent for 5 minutes
  global bMotionInfo silenceAways
  if {$bMotionInfo(silence) == 1} {
    #I already am :P
    putserv "NOTICE $nick :I already am silent :P"
    return 0
  }
  timer 5 bMotionUnSilence
  putlog "bMotion: Was told to be silent for 5 minutes by $nick in $channel"
  set awayStuff [pickRandom $silenceAways]
  bMotionDoAction $channel $nick $awayStuff
  putserv "AWAY :bbi5 ($nick $channel)"
  set bMotionInfo(silence) 1
  set bMotionInfo(away) 1
}

proc bMotionUnSilence {} {
  # Timer for silence expires
  putserv "AWAY"
  putlog "bMotion: No longer silent."
  global bMotionInfo
  set bMotionInfo(silence) 0
  set bMotionInfo(away) 0
}

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

proc bMotionGetGender { nick host } {
  set host "$nick!$host"
  set handle [finduser $host]
  if {$handle == "*"} {
    return "unknown"
  }
  # found a user, now get their gender
  return [getuser $handle XTRA gender]
}

proc pastWatershedCheck { nick } {
  return 1
  set hour [getHour]
  global bMotionInfo
  if {($hour < $bMotionInfo(upperWatershed)) && ($hour > $bMotionInfo(lowerWatershed))} {
    global bMotionInfo
    putserv "NOTICE $nick :I'd love to, but it's before the watershed so I'm not allowed to do that. Try asking me again after $bMotionInfo(upperWatershed):00"
    return 0
  }
  return 1
}

proc loldec {} {
  global bMotionCache
  if {$bMotionCache(LOLcount) > 0} {
    incr bMotionCache(LOLcount) -1
  }
  utimer 5 loldec
}

proc getHour {} {
  return [clock format [clock seconds] -format "%H"]
}

proc bMotion_dcc_command { handle idx arg } {
  global bMotionInfo
  bMotion_putloglev 2 * "bMotion: admin command $arg from $handle"
  set info [bMotion_plugin_find_admin $arg $bMotionInfo(language)]
  if {$info == ""} {
    putidx $idx "What? You need .bmhelp!"
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

proc bMotion_dcc_help { handle idx arg } {
  putidx $idx "Commands available: (Some may not be accessible by you)\r"

  set cmds ""
  
  global bMotion_plugins_admin
  set s [array startsearch bMotion_plugins_admin]
  while {[set key [array nextelement bMotion_plugins_admin $s]] != ""} {
    if {$key == "dummy"} { continue }
    append cmds "$key     "
  }

  putidx $idx "$cmds\r"
  array donesearch bMotion_plugins_admin $s
}

proc dcc_bmotioncommand { handle idx arg } {
  if [regexp -nocase "redo botnicks" $arg] {
    putidx $idx "!bMotion! now redoing botnicks..."
    global botnicks botnick bMotionSettings
    set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
    putidx $idx "!bMotion! botnicks are now: $botnicks"
    return 1
  }

  if [regexp -nocase "reload" $arg] {
    putidx $idx "!bMotion! reloading randoms file"
    source scripts/bMotionSettings.tcl
    return 1
  }

  if [regexp -nocase "unsilence" $arg] {
    global bMotionInfo
    putserv "AWAY"
    putidx $idx "No longer silent."
    set bMotionInfo(silence) 0
    set bMotionInfo(away) 0    
    return 1
  }

  if [regexp -nocase "unbind votes" $arg] {
      putidx $idx "Unbinding vote commands...\n"
      unbind pub - "!innocent" bMotionVoteHandler
      unbind pub - "!guilty" bMotionVoteHandler
      unbind pubm - "!innocent" bMotionVoteHandler
      unbind pubm - "!guilty" bMotionVoteHandler
      putidx $idx "ok\n"
      return 1
  }
 
  return 1
}

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
    putserv "AWAY";
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


proc msg_bmotioncommand { nick host handle arg } {
  return 0
}

proc smileyhandler {} {
  global bMotionInfo bMotionCache
  foreach channel $bMotionInfo(randomChannels) {
    set chanMood $bMotionCache($channel,mood)
    if [rand 2] {
      if {$chanMood != 0} {
        #don't talk to ourselves
        if {$bMotionCache($channel,last) == 0} {
          bMotionDoAction $channel "" [makeSmiley $chanMood]
        }
      }
    }
  #end foreach
  }
}


# Time stuff
 set pronounce {vigintillion novemdecillion octodecillion \
        septendecillion sexdecillion quindecillion quattuordecillion \
        tredecillion duodecillion undecillion decillion nonillion \
        octillion septillion sextillion quintillion quadrillion \
        trillion billion million thousand ""}

 proc get_num num {
    foreach {a b} {0 {} 1 one 2 two 3 three 4 four 5 five 6 six 7 seven \
            8 eight 9 nine 10 ten 11 eleven 12 twelve 13 thirteen 14 \
            fourteen 15 fifteen 16 sixteen 17 seventeen 18 eighteen 19 \
            nineteen 20 twenty 30 thirty 40 forty 50 fifty 60 sixty 70 \
            seventy 80 eighty 90 ninety} {if {$num == $a} {return $b}}
    return $num
 }


 proc revorder list {
    for {set x 0;set y [expr {[llength $list] - 1}]} {$x < $y} \
	    {incr x;incr y -1} {
	set t [lindex $list $x]
	set list [lreplace $list $x $x [lindex $list $y]]
	set list [lreplace $list $y $y $t]
    }
    return $list
 }

 proc pron_form num {
    global pronounce
    set x [join [split $num ,] {}]
    set x [revorder [split $x {}]]
    set pron ""
    set ct [expr {[llength $pronounce] - 1}]
    foreach {a b c} $x {
	set p [pron_num $c$b$a]
	if {$p != ""} {
	    lappend pron "$p [lindex $pronounce $ct]"
	}
	incr ct -1
    }
    return [join [revorder $pron] ", "]
 }

proc bMotion_get_number { num } {
  set hundred ""
  set ten ""
  set len [string length $num]
  if {$len == 3} {
    set hundred "[get_num [string index $num 0]] hundred"
    set num [string range $num 1 end]
  }
  if {$num > 20 && $num != $num/10} {
    set tens [get_num [string index $num 0]0]
    set ones [get_num [string index $num 1]]
    set ten [join [concat $tens $ones] -]
  } else {
    set ten [get_num $num]
  }
  if {[string length $hundred] && [string length $ten]} {
    return [concat $hundred and $ten]
  } else {
    # One of these is empty, but don't bother to work out which!
    return [concat $hundred $ten]
  }
}

proc bMotion_startTimers { } { 
  global mooddrifttimer
	if  {![info exists mooddrifttimer]} {
		timer 10 driftmood
    utimer 5 loldec
    timer [expr [rand 30] + 3] doRandomStuff
		set mooddrifttimer 1
    set delay [expr [rand 200] + 1700]
    utimer $delay bMotion_interbot_next_elect
	}
}


bMotion_putloglev d * "bMotion: system module loaded"
