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


### doRandomStuff <<<1
proc doRandomStuff {} {
  global bMotionInfo mood stonedRandomStuff bMotionSettings
  global bMotionLastEvent bMotionOriginalNick bMotionChannels

  set timeNow [clock seconds]
  set saidChannels [list]
  set silentChannels [list]
  set bMotionOriginalNick ""

	bMotion_update_chanlist

  #do this first now
  set upperLimit [expr $bMotionInfo(maxRandomDelay) - $bMotionInfo(minRandomDelay)]
  if {$upperLimit < 1} {
  	set upperLimit 1
  }
  set temp [expr [rand $upperLimit] + $bMotionInfo(minRandomDelay)]
  timer $temp doRandomStuff
  bMotion_putloglev d * "bMotion: randomStuff next ($temp minutes)"


  #not away

  #find the most recent event
  set mostRecent 0
  set line "comparing idle times: "
  foreach channel $bMotionChannels {
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

  if {[bMotion_setting_get "bitlbee"]} {
    #never go away in bitlbee
    set idleEnough 0
  }

  #override if we should never go away
  if {$bMotionSettings(useAway) == 0} {
    set idleEnough 0
  }

  if {$idleEnough} {
    if {$bMotionInfo(away) == 1} {
      #away, don't do anything
      return 0
    }

    #channel is quite idle
    if {[rand 4] == 0} {
      putlog "bMotion: All channels are idle, going away"
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
  bMotion_counter_incr "system" "randomstuff"
	if {[bMotion_setting_get "bitlbee"] == "1"} {
		return 0
	}

  foreach channel $bMotionChannels {
    if {(($timeNow - $bMotionLastEvent($channel)) < ($bMotionInfo(maxIdleGap) * 60))} {
      lappend saidChannels $channel
      bMotionSaySomethingRandom $channel
    } else {
      lappend silentChannels $channel
    }
  }
  bMotion_putloglev d * "bMotion: randomStuff said ($saidChannels) silent ($silentChannels)"
}

### bMotionSaySomethingRandom <<<1
proc bMotionSaySomethingRandom {channel} {
  global randomStuff stonedRandomStuff randomStuffMale randomStuffFemale mood bMotionInfo bMotionCache

	if ($bMotionCache($channel,last)) {
		return 1
	}

  if [rand 2] {
    bMotionDoAction $channel "" "%VAR{randomStuff}"
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
  if [regexp -nocase "(^${botnicks}:?|${botnicks}\\?$)" $text] {
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
  set awayStuff [pickRandom $silenceAways]
  bMotionDoAction $channel $nick $awayStuff
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
	if  {![info exists mooddrifttimer]} {
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

bMotion_putloglev d * "bMotion: system module loaded"
