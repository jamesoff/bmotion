#bMotion - Output functions
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

proc pickRandom { list } {
  return [lindex $list [rand [llength $list]]]
}

proc getPronoun {} {
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "himself" }
  if {$bMotionInfo(gender) == "female"} { return "herself" }
  return "itself"
}

proc getHisHers {} {
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "his" }
  if {$bMotionInfo(gender) == "female"} { return "hers" }
  return "its"
}

proc getHisHer {} {
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "his" }
  if {$bMotionInfo(gender) == "female"} { return "her" }
  return "it"
}


proc getHeShe {} {
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "he" }
  if {$bMotionInfo(gender) == "female"} { return "she" }
  return "it"
}


proc mee {channel action} {
  #puthelp "PRIVMSG $channel :\001ACTION $action\001"
  global bMotionQueue
  bMotionQueueCheck
  lappend bMotionQueue "PRIVMSG $channel :\001ACTION $action\001"

}


## bMotionDoAction ###########################################################
proc bMotionDoAction {channel nick text {moreText ""} {noTypo 0}} {
  bMotion_putloglev 4 * "bMotion: bMotionDoAction($channel,$nick,$text,$moreText,$noTypo)"
  global bMotionInfo bMotionCache
  set bMotionCache($channel,last) 1
  set bMotionCache(typos) 0
  set bMotionCache(typoFix) ""

  set channel [string tolower $channel]
  if {[lsearch $bMotionInfo(randomChannels) [string tolower $channel]] < 0} {
    bMotion_putloglev d * "bMotion: aborting bMotionDoAction ... $channel not allowed"
    return 0
  }

  if {$bMotionInfo(silence) == 1} { return 0 }
  if {$bMotionInfo(adminSilence,$channel) == 1} { return 0 }

  set chance [rand 3]
  switch [rand 3] {
    0 { }
    1 { set nick [string tolower $nick] }
    2 { set nick "[string range $nick 0 0][string tolower [string range $nick 1 end]]" }
  } 

  #choose a remote bot
  if [regexp -nocase "%bot" $text] {
    set thisBot [bMotionChooseRandomBot $channel]
    bMotion_putloglev d * "bMotion: Chosen bot $thisBot"
    set bMotionCache(remoteBot) $thisBot
    if {$thisBot == ""} {
      putlog "bMotion: ALERT! While trying to say !$text! to $channel couldn't find a bot to talk to. Lost entire output."
      return 0
    }
  }

  #choose a remote user
  if [regexp -nocase "%ruser" $text] {
    set ruser [bMotionChooseRandomUser $channel]
    bMotion_putloglev d * "bMotion: Chosen user $ruser"
    set bMotionCache(randomUser) $ruser
  }


  #do this first now
  set text [bMotionDoInterpolation $text $nick $moreText $channel]

  set multiPart 0
  if [string match "*%|*" $text] {
    set multiPart 1
    # we have many things to do
    set thingsToSay ""
    set loopCount 0
    set blah 0
    
    #make sure we get the last section
    set text "$text%|"

    while {[string match "*%|*" $text]} {
      set sentence [string range $text 0 [expr [string first "%|" $text] -1]]
      if {$sentence != ""} { 
        if {$blah == 0} {
          set thingsToSay [list $sentence] 
          set blah 1
        } else {
          lappend thingsToSay $sentence
        }
      }
      set text [string range $text [expr [string first "%|" $text] + 2] end]
      incr loopCount
      if {$loopCount > 20} { 
        putlog "bMotion ALERT! Bailed in bMotionDoAction with $text. Lost output."
        return 0
      }
    }
  }

  if {$multiPart == 1} {
    foreach lineIn $thingsToSay {
      set temp [bMotionSayLine $channel $nick $lineIn $moreText $noTypo]
      if {$temp == 1} {
        bMotion_putloglev 1 * "bMotion: bMotionSayLine returned 1, skipping rest of output"
        #1 stops continuation after a failed %bot[n,]
        break
      }
    }
    set typosDone [bMotion_plugins_settings_get "output:typos" "typosDone" "" ""]
    bMotion_putloglev 2 * "bMotion: typosDone (multipart) is !$typosDone!"
    if {$typosDone != ""} {
      bMotion_plugins_settings_set "output:typos" "typosDone" "" "" ""
      bMotion_plugins_settings_set "output:typos" "typos" "" "" ""      
      if [rand 2] {
        bMotionDoAction $channel "" "%VAR{typoFix}" "" 1
      }

    }
    return 0
  }

  bMotionSayLine $channel $nick $text $moreText $noTypo
  set typosDone [bMotion_plugins_settings_get "output:typos" "typosDone" "" ""]
  bMotion_putloglev 2 * "bMotion: typosDone is !$typosDone!"
  if {$typosDone != ""} {
    bMotion_plugins_settings_set "output:typos" "typosDone" "" "" ""
    bMotion_plugins_settings_set "output:typos" "typos" "" "" ""    
    if [rand 2] {
      bMotionDoAction $channel "" "%VAR{typoFix}" "" 1
    }
  }

  return 0
}

proc bMotionDoInterpolation { line nick moreText { channel "" } } {
  global botnick sillyThings bMotionCache

  #drop out immediately if this is a %BOT
  #if [regexp -nocase "^%BOT" $line] {
  #  return $line
  #}

  set loops 0
  while {[regexp "%VAR\{(.+?)\}" $line matches BOOM]} {
    global $BOOM
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %VAR code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    set var [subst $$BOOM]
    set line [bMotionInsertString $line "%VAR\{$BOOM\}" [pickRandom $var]]
  }

  set loops 0
  while {[regexp "%SETTING\{(.+?)\}" $line matches settingString]} {
    if [regexp {([^:]+:[^:]+):([^:]+):([^:]+):([^:]+)} $settingString matches plugin setting ch ni] {
      set var [bMotion_plugins_settings_get $plugin $setting $ch $ni]
    }
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %SETTING code with $line"
      set line "/has a tremendous error while trying to infer the meaning of life :("
    }
    set line [bMotionInsertString $line "%SETTING{$settingString}" $var]
  }
  
  set loops 0
  while {[regexp "%NUMBER\{(.+?)\}" $line matches numberString]} {
    set var [bMotion_get_number [rand $numberString]]
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %NUMBER code with $line"
      set line "/has a tremendous error while trying to think of a number :("
    }
    set line [bMotionInsertString $line "%NUMBER\\{$numberString\\}" $var]
  }

  set line [bMotionInsertString $line "%%" $nick]
  set line [bMotionInsertString $line "%pronoun" [getPronoun]]
  set line [bMotionInsertString $line "%me" $botnick]
  set line [bMotionInsertString $line "%noun" [pickRandom $sillyThings]]
  set line [bMotionInsertString $line "%colen" [bMotionGetColenChars]]
  set line [bMotionInsertString $line "%hishers" [getHisHers]]
  set line [bMotionInsertString $line "%heshe" [getHeShe]]
  set line [bMotionInsertString $line "%hisher" [getHisHer]]
  set line [bMotionInsertString $line "%2" $moreText]
  set line [bMotionInsertString $line "%percent" "%"]
  #ruser moved
  #rbot moved
  return $line
}

proc bMotionSayLine {channel nick line {moreText ""} {noTypo 0}} {
  global mood botnick bMotionInfo sillyThings bMotionCache

  #choose a new bot?
  if [regexp {^%PICKBOT\[(.+)?\]} $line matches conditions] {
    #pick a bot
    set thisBot [bMotionChooseRandomBot $channel $conditions]
    bMotion_putloglev d * "bMotion: Chosen new bot $thisBot"
    set bMotionCache(remoteBot) $thisBot
    if {$thisBot == ""} {
      putlog "bMotion: ALERT! Can't find a bot matching conditions !$conditions! in $channel to talk to. Lost output."
      return 1
    }
    return 0
  }

  #choose a new user?
  if [regexp {^%PICKUSER\[(.+)?\]} $line matches conditions] {
    set ruser [bMotionChooseRandomUser $channel $conditions]
    bMotion_putloglev d * "bMotion: Chosen new user $ruser"
    set bMotionCache(randomUser) $ruser
    return 0
  }

  #safe to do these here
  #try to get sensible names
  set uhost [getchanhost $bMotionCache(randomUser)]
  set ruser [bMotionGetRealName $bMotionCache(randomUser) $uhost]
  set line [bMotionInsertString $line "%ruser" $ruser]

  set uhost [getchanhost $bMotionCache(remoteBot)]
  putloglev 3 * "bMotion: remote bothost = $uhost"
  set rbot [bMotionGetRealName $bMotionCache(remoteBot) $uhost]
  putloglev 3 * "bMotion: remote bot nick = $rbot"
  set line [bMotionInsertString $line "%rbot" $rbot]

  #owners
  set loops 0
  while {[regexp -nocase "%OWNER\{(.+?)\}" $line matches BOOM]} {
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %OWNER code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    set line [bMotionInsertString $line "%OWNER\{$BOOM\}" [bMotionMakePossessive $BOOM]]
  }


  #if it's a bot , put it on the queue with no more processing
  if [regexp -nocase {%(BOT)\[(.+?)\]} $line matches botcmd cmd] {
    set dobreak 0
    if {$botcmd == "bot"} {
      #random
      bMotion_putloglev 1 * "bMotion: %bot detected"
      regexp {%bot\[([[:digit:]]+),(.+)\]} $line matches chance cmd
      bMotion_putloglev 1 * "bMotion: %bot chance is $chance"
      set dobreak 1
      if {[rand 100] < $chance} {
        set line "%BOT\[$cmd\]"
        set dobreak 0
      } else {
        set line ""
      }
    }

    if {$line != ""} {
      global bMotionQueue
      bMotionQueueCheck
      append line " $bMotionCache(remoteBot)"
      bMotion_putloglev 1 * "bMotion: queuing botcommand !$cmd! for output"
      lappend bMotionQueue "$channel $line"
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


  if {$mood(stoned) > 3} {
    if [rand 2] {
      set line "$line man.."
    } else {
      if [rand 2] {
        set line "$line dude..."
      }
    }
  }

  # Run the plugins :D

  if {$noTypo == 0} {
    set plugins [bMotion_plugin_find_output $bMotionInfo(language)]
    if {[llength $plugins] > 0} {
      foreach callback $plugins {
        bMotion_putloglev 1 * "bMotion: output plugin: $callback..."
        catch {
          set result [$callback $channel $line]
        } err
        bMotion_putloglev 3 * "bMotion: returned from output $callback ($result)"
        if [regexp "1¦(.+)" $result matches line] {
          break
        }
        set line $result
      }
    }
  }

  #check if this line matches the last line said on IRC
  global bMotionThisText
  if [string match -nocase $bMotionThisText $line] {
    bMotion_putloglev 1 * "bMotion: my output matches the trigger, dropping"
    return 0
  }

  if [regexp "^/" $line] {
    set line [bMotionInsertString $line "%slash" "/"]
    #it's an action
    mee $channel [string range $line 1 end]
  } else {
    global bMotionQueue
    set line [bMotionInsertString $line "%slash" "/"]
    bMotionQueueCheck
    bMotion_putloglev 1 * "bMotion: queuing !PRIVMSG $channel :$line! for output"
    lappend bMotionQueue "PRIVMSG $channel :$line"
  }
  return 0
}

proc bMotionInsertString {line swapout toInsert} {
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

proc bMotionGetColenChars {} {
  set randomChar "!£$%^*@#~"

  set randomChars [split $randomChar {}]

  set length [rand 12]
  set length [expr $length + 5]

  set line ""

  while {$length >= 0} {
    incr length -1
    append line [pickRandom $randomChars]
  }

  regsub -all "%%" $line "%percent" line

  return $line
}

proc makeSmiley { mood } {
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

## Wash nick
#    Attempt to clean a nickname up to a proper name
#
proc bMotionWashNick { nick } {
  # strip numbers off the nick
  #putlog "Examining $nick"
  if [regexp -nocase {^([[:digit:]]+)?([[:alpha:]]+)([[:digit:]]{2,})?$} $nick matches numbers1 stem numbers2] {
    #putlog "Stripping surrounding numbers"
    set nick $stem
  }

  #strip `'- and |s off beginning and end
  if [regexp -nocase {^[\|`\'\-\_^\[\]\{\}]?([[:alnum:]]+)[\|`\'\-\_^\[\]\{\}]?$} $nick matches stem] {
    #putlog "Stripping surrounding |s"
    set nick $stem
  }

  #try for numbers again, just in case
  if [regexp -nocase {^([[:digit:]]+)?([[:alpha:]]+)([[:digit:]]{2,})?$} $nick matches numbers1 stem numbers2] {
    #putlog "Stripping surrounding numbers again"
    set nick $stem
  }

  #slice after `'-^_ and |
  if [regexp -nocase {^([[:alnum:]]+)[`\'\|\-^_\[\]\{\}].*} $nick matches stem] {
    set nick $stem
  }

  return $nick
}

proc bMotionGetRealName { nick { host "" }} {
  bMotion_putloglev 4 * "bMotion: bMotionGetRealName($nick,$host)"

  #is it me?
  global botnicks
  set first {[[:<:]]}
  set last {[[:>:]]}
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
  putloglev 2 * "bMotion: found $handle, IRLs are $realname"
  return [pickRandom $realname]
}

proc bMotionTransformNick { target nick {host ""} } {
  set newTarget [bMotionTransformTarget $target $host]
  if {$newTarget == "me"} {
    set newTarget $nick
  }
  return $newTarget
}

proc bMotionTransformTarget { target {host ""} } {
  global botnicks
  if {$target != "me"} {
    set t [bMotionGetRealName $target $host]
    bMotion_putloglev 2 * "bMotion: bMotionGetName in bMotionTransformTarget returned $t"
    if {$t != "me"} {
      set target $t
    }
  } else {
    set himself {[[:<:]](your?self|}
    append himself $botnicks
    append himself {)[[:>:]]}
    if [regexp -nocase $himself $target] {
      set target [getPronoun]
    }
  }
  return $target
}

proc bMotionProcessQueue { } {
  global bMotionQueue bMotionQueueTimer
  set bMotionQueueTimer 0
  if {[llength $bMotionQueue] > 0} {
    set next [lindex $bMotionQueue 0]
      bMotion_putloglev 1 * "bMotion: processing queue, [llength $bMotionQueue] items remaining !$next!"
    #maximum of 15 items in queue
    set bMotionQueue [lrange $bMotionQueue 1 15]
    set done 0

    #check if it needs to go to a bot
    if [regexp {(#[^ ]+) %BOT\[(.+?)\] (.+)} $next matches channel cmd bot] {
      bMotion_putloglev 2 * "bMotion: matched 100% bot command for channel $channel -> $cmd"
      global bMotionQueue
      #bMotionQueueCheck
      bMotionSendSayChan $channel $cmd $bot
      set done 1
    }

    if [regexp {(#[^ ]+) %bot\[([[:digit:]]+),(.+?)\] (.+)} $next matches channel chance cmd bot] {
      #push to a bot
      bMotion_putloglev 2 * "bMotion: matched $chance% bot command for channel $channel -> $cmd"
      if {[rand 100] < $chance} {
        bMotionSendSayChan $channel $cmd $bot
      }
      set done 1
    }
    if {$done == 0} { puthelp $next }
    if {[llength $bMotionQueue] == 0} {
      bMotion_putloglev 1 * "bMotion: done queue"
      return 0
    }    

    set next [lindex $bMotionQueue 0]
    set delay [expr round([string length $next] / 5)]
    if [string match -nocase "%bot*" $next] {
      set delay 5
    }
    if {$delay > 7} {
      set delay 6
    }
    bMotion_putloglev d * "bMotion: delay for next line: $delay (+ random)"

    set bMotionQueueTimer 1
    utimer [expr [rand 3] + $delay] bMotionProcessQueue
  } else {
    #0-length queue!
    putlog "bMotion: WARNING! bMotionProcessQueue ran with no queue (possibly result of a .bmotion flush queue)"
  }
}

proc bMotionQueueCheck { { initialDelay 2 } } {
  #called just before an output function queues something
  #if the timer needs to be run, run it
  global bMotionQueue bMotionQueueTimer
  if {([llength $bMotionQueue] == 0) && ($bMotionQueueTimer == 0)} {
    bMotion_putloglev 1 * "bMotion: starting queue timer ($initialDelay)"
    utimer $initialDelay bMotionProcessQueue
    set bMotionQueueTimer 1
  }
}

proc bMotionChooseRandomUser { channel { conditions ""}} {
  bMotion_putloglev 2 * "bMotion: looking for a $conditions user"
  global botnick
  set users [chanlist $channel]
  if {[llength $users] < 2} {
    return $botnick
  }

  set userslist [list]
  foreach user $users {
    set handle [nick2hand $user]
    if [matchattr $handle b] {
      continue
    }
    if {$conditions != ""} {
      if [string match -nocase [getuser $handle XTRA gender] $conditions] {
        lappend userslist $user
        bMotion_putloglev 1 * "bMotion: accepting user $handle for gender $conditions"
      } else {
        if {($conditions == "like") && [bMotionLike $user [getchanhost $user]]} {
          lappend userslist $user
        } else {
          bMotion_putloglev 2 * "bMotion: rejecting $handle on gender" 
        }
      }
    } else {
      lappend userslist $user
    }
  }
  bMotion_putloglev 1 * "bMotion: found [llength $userslist] users in $channel, $userslist"
  set users $userslist
  if {[llength $users] == 0} {
    return ""
  }

  if {[llength $users] == 1} {
    return [lindex $users 0]
  }

  set ruser $botnick
  while {$ruser == $botnick} {
    set ruser [lindex $users [rand [llength $users]]]
  }
  return $ruser
}

proc bMotionChooseRandomBot { channel { conditions "" }} {
  bMotion_putloglev 1 * "bMotion: checking $channel"
  global botnick bMotionInfo
  set bots [chanlist $channel]
  set botslist [list] 
  foreach bot $bots {
    if [isbotnick $bot] { continue }
    set handle [nick2hand $bot $channel]
    bMotion_putloglev 1 * "bMotion: checking $bot ($handle)"
    if [matchattr [nick2hand $bot $channel] b&K $channel] {
      if {$conditions != ""} {
        if [string match -nocase [getuser $handle XTRA gender] $conditions] {
          lappend botslist $bot
        } else {
          if {($conditions == "like") && [bMotionLike $bot [getchanhost $bot]]} {
            lappend botslist $bot
          } else {
            bMotion_putloglev 1 * "bMotion: bot $handle's gender doesn't match"
          }
        }
      } else {
        lappend botslist $bot
      }
    }
  }
  set bots $botslist
  bMotion_putloglev 1 * "bMotion: found [llength $bots] bots in $channel, $bots"
  #one or fewer means we only found us (or noone)
  if {[llength $bots] == 0} {
    return ""
  }

  set rbot $botnick
  while {$rbot == $botnick} {
    set rbot [lindex $bots [rand [llength $bots]]]
  }
  return $rbot
}

proc bMotionMakePossessive { text { altMode 0 }} {
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


bMotion_putloglev d * "bMotion: events module loaded"
