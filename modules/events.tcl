# bMotion - Event handling
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

# call an irc event response plugin
proc bMotionDoEventResponse { type nick host handle channel text } {
  bMotion_putloglev 4 * "entering bMotionDoEventResponse: $type $nick $host $handle $channel $text"
  if { ![regexp -nocase "nick|join|quit|part|split" $type] } {
    return 0
  }

  global bMotionInfo
  set response [bMotion_plugin_find_irc_event $text $type $bMotionInfo(language)]
  if {[llength $response] > 0} {
    foreach callback $response {
      bMotion_flood_add $nick $callback $text
      if [bMotion_flood_check $nick] { return 0 }

      bMotion_putloglev 1 * "bMotion: matched irc event plugin, running callback $callback"
      set result [$callback $nick $host $handle $channel $text ]
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

## BEGIN onjoin handler
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

  set result [bMotionDoEventResponse "join" $nick $host $handle $channel "" ]
}
## END onjoin


## BEGIN onpart handler
proc bMotion_event_onpart {nick host handle channel {msg ""}} {
  bMotion_putloglev 3 * "entering bmotion_event_onpart: $nick $host $handle $channel $msg"
  global bMotionCache

  set bMotionCache(lastLeft) $nick

  #TODO: Fix this? Passing a cleaned nick around can break things
  set nick [bMotion_cleanNick $nick $handle]

  set result [bMotionDoEventResponse "part" $nick $host $handle $channel $msg]
}
## END onpart


## BEGIN onquit handler
proc bMotion_event_onquit {nick host handle channel reason} {
  global bMotionCache bMotionSettings bMotionInfo

  set nick [bMotion_cleanNick $nick $handle]

  if {$bMotionSettings(needI) == 1} {
    set bMotionCache(lastLeft) $nick
  }

  if {$bMotionInfo(brig) != ""} {
    #check if that person was in the brig
    regexp -nocase "(.+)@(.+)" $bMotionInfo(brig) pop brigNick brigChannel
    if [string match -nocase $nick $brigNick] {
      set bMotionInfo(brig) ""
      bMotionDoAction $brigChannel "" "Curses! They escaped from the brig."
      return 0
    }
  }
  set result [bMotionDoEventResponse "quit" $nick $host $handle $channel $reason ]
}
## END onquit

# BEGIN main interactive
proc bMotion_event_main {nick host handle channel text} {
  ## Global definitions ##
  global mood botnick gretings welcomes sorryoks
  global loveresponses boreds upyourbums smiles
  global arrs botnick arrcachenick arrcachearr
  global bMotionLastEvent bMotionSettings botnicks bMotionCache bMotionInfo
  global bMotionThisText bMotionOriginalInput

  if [matchattr $handle J] {
    return 0
  }

  set channel [string tolower $channel]

  #ignore other bots
  if {[matchattr $handle b] && (![matchattr $handle I])} {
    set bMotionCache($channel,last) 0
    return 0
  }

  if {[lsearch $bMotionInfo(randomChannels) $channel] == -1} {
    return 0
  }

  bMotion_putloglev 4 * "bMotion: entering bMotion_event_main with nick: $nick host: $host handle: $handle chan: $channel text: $text"

  #set nick [bMotion_cleanNick $nick $handle]

  set bMotionOriginalInput $text

  #filter bold codes out
  regsub -all "\002" $text "" text
  regsub -all "\022" $text "" text
  regsub -all "\037" $text "" text
  regsub -all "\003\[0-9\]+(,\[0-9+\])?" $text "" text

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
  }

  ## Update the channel idle tracker ##
  set bMotionLastEvent($channel) [clock seconds]

  #ignore lines with <nobotnick> tags
  if [regexp -nocase "\</?no$botnicks\>" $text] {return 0}
  if [regexp -nocase "\<no$botnicks\>" $text] {return 0}

  #don't let people break us
  if {![matchattr $handle n]} {
    if [regexp -nocase "%(pronoun|me|noun|colen|percent|VAR|\\|)" $text] {
      regsub -all "%" $text "%percent" text
    }
  }
  regsub -all "/" $text "%slash" text

  ## If this isn't just a smiley of some kind, trim smilies
  if {[string length $text] >= ([string length $botnick] + 4)} {
    regsub -all -nocase {[;:=]-?[)D>]} $text "" text
    regexp -all {([\-^])_*[\-^];*} $text "" text
  }

  ## Trim ##
  set text [string trim $text]

  ## Dump double+ spaces #
  regsub -all "  +" $text " " text


  ## Update the last-talked flag for the join system
  bMotion_plugins_settings_set "system:join" "lasttalk" "channel" "" 0

  set bMotionThisText $text

  #if we spoke last, add "$botnick: " if it's not in the line
  if {![regexp -nocase $botnicks $text] && $bMotionCache($channel,last)} {
    set text "${botnick}: $text"
  }

  #check for someone breaking the loop of lastSpoke
  if {[regexp -nocase "(i'm not talking to|not) you" $text] && $bMotionCache($channel,last)} {
    bMotionDoAction $channel $nick "oh"
    set bMotionCache($channel,last) 0
    return 0
  }
  set bMotionCache($channel,last) 0

  ## Run the simple plugins ##
  set response [bMotion_plugin_find_simple $text $bMotionInfo(language)]
  if {$response != ""} {
    bMotion_flood_add $nick "" $text
    if [bMotion_flood_check $nick] { return 0 }
    set nick [bMotionGetRealName $nick $host]
    bMotionDoAction $channel $nick [pickRandom $response]
    return 0
  }

  ## Run the complex plugins ##
  set response [bMotion_plugin_find_complex $text $bMotionInfo(language)]
  if {[llength $response] > 0} {
    #set nick [bMotionGetRealName $nick $host]
    foreach callback $response {
      bMotion_flood_add $nick $callback $text
      if [bMotion_flood_check $nick] { return 0 }

      bMotion_putloglev 1 * "bMotion: matched complex plugin, running callback $callback"
      set result [$callback $nick $host $handle $channel $text]
      set bMotionCache(lastPlugin) $callback
      if {$result == 1} {
        bMotion_putloglev 2 * "bMotion: $callback returned 1, breaking out..."
        break
      }
    }
    return 0
  }


  #Check for all caps
  regsub -all {[^A-Za-z]} $text "" textChars
  regsub -all {[a-z]} $textChars "" textLowerChars
  if {(([string length $textChars] > 4) && ([expr [string length $textLowerChars] / [string length $textChars]] > 0.9)) ||
        [regexp ".+!{4,}" $text]} {
    global blownAways
    if {[rand 60] >= 55} {
      bMotionDoAction $channel $nick [pickRandom $blownAways]
      return 0
    }
  }

  ################################# Things that can be responded to from everyone ##########################

  ## Reload config files
  ## Requires global +m
  if [regexp -nocase "${botnicks},?:? re(hash|load)( your config files?)?" $text] {
    putlog "bMotion: $nick asked me to rehash in $channel"
    global bMotionCache bMotion_testing bMotionRoot

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
      set bMotionCache(rehash) $channel
      set bMotion_testing 0
      if {[matchattr $handle m]} {
        putchan $channel [bMotionDoInterpolation "%VAR{rehashes}" "" ""]
        rehash
        return 0
      }
    }
    bMotionDoAction $channel $nick "I think not."
    return 0
  }
  ## /Reload config files

  if [regexp -nocase "${botnicks}:? what ver(sion )?(of )?bmotion are you (running|using)\\?" $text] {
    global bMotionVersion
    bMotionDoAction $channel $nick "I'm running bMotion $bMotionVersion (http://bmotion.sf.net)"
    return 0
  }

  ## ignore channels that aren't in the randoms list ##
  if {[lsearch $bMotionInfo(randomChannels) [string tolower $channel]] == -1} {
    return 0
  }

  ####whole-line matches

  ## tell the names we have
  if [regexp -nocase "${botnicks}:?,? say my names?(,? bitch)?" $text] {
    set realnames [getuser $handle XTRA irl]
    if {$realnames == ""} {
      bMotionDoAction $channel $nick "Ah you must be %%." "" 1
    } else {
      bMotionDoAction $channel $nick "Your IRL name(s) are:\002 %2 \002" $realnames 1
    }
    puthelp "NOTICE $nick :To update your IRL names, do \002/msg $botnick IRL name1 name2 name3 ...\002"
    return 0
  }

  ## happy xmas
  ## --> and to you too
  if {[regexp -nocase "(merry|happy|have a good) (xmas|christmas|chrismas|newyear|new year) $botnicks" $text]} {
    incr mood(happy) 1
    incr mood(lonely) -1
    bMotionDoAction $channel [bMotionGetRealName $nick $host] ":) merry christmas and happy new year %%"
    set bMotionCache(lastDoneFor) $nick
    driftFriendship $nick 3
    return 0
  }

  if [regexp -nocase "${botnicks}?:? ?(how('?s|z) it going|hoe gaat het|what'?s up|'?sup|how are you),?( ${botnicks})?\\?" $text] {
    global mood
    driftFriendship $nick 2

    if {![bMotionTalkingToMe $text]} { return 0 }

    if {$bMotionCache(lastHows) != $nick} {
      set moodString "I'm feeling "
      set moodIndex 0
      if {$mood(lonely) > 5} {
        append moodString "a bit lonely"
        incr moodIndex -2
      }

      if {$mood(horny) > 2} {
        if {[string length $moodString] > 13} {
          append moodString ", "
        }
        append moodString "a little horny"
        incr moodIndex 2
      }

      if {$mood(happy) > 3} {
        if {[string length $moodString] > 13} {
          append moodString ", "
        }
        append moodString "happy"
        incr moodIndex 1
      }

      if {$mood(happy) < 0} {
        if {[string length $moodString] > 13} {
          append moodString ", "
        }
        append moodString "sad"
        incr moodIndex -3
      }

      if {$mood(stoned) > 5} {
        if {[string length $moodString] > 13} {
          append moodString ", "
        }
        append moodString "stoned off my tits"
        incr moodIndex 2
      }

      if {$moodIndex >= 0} {
        append moodString " :)"
      } else {
        append moodString " :("
      }

      if {[string length $moodString] == [string length "I'm feeling  :)"]} {
        global feelings
        set moodString [pickRandom $feelings]
      }

      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%%: $moodString"
      return 0
    }
    return 0
  }

  ###################################### +I people only ###################################################

  if {$bMotionSettings(needI) == 1} {
    if {![matchattr $handle I]} {return 0}
  }

  ## kill [with item]
  ## --> kill [with item]
  ## /kill

  ## shut up
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
  ## /shutup

  ##fuck off

  ## attack


  ## choose you

  ## return (now a simple plugin)

  ## i didn't (now a simple plugin)

  ## team rocket :D
  if [regexp -nocase "^Prepare for trouble!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != ""} {
      if {$bMotionCache(teamRocket) != $nick} {
        putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
        return 0
      }
      putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
      return 0
    }
    set bMotionCache(teamRocket) $nick
    timer 3 { bMotionEndTeamRocket }
    bMotionDoAction $channel $nick "...and make it double"
    return 0
  }

  if [regexp -nocase "^\.*and make it double!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != $nick} {
      putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
      return 0
    }
    if {$bMotionCache(teamRocket) == ""} {
      return 0
    }
    bMotionDoAction $channel $nick "To unite all people within our nation"
    return 0
  }

  if [regexp -nocase "^To protect the world from devastation!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != $nick} {
      putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
      return 0
    }
    if {$bMotionCache(teamRocket) == ""} {
      return 0
    }
    bMotionDoAction $channel $nick "To unite all people within our nation"
    return 0
  }

  if [regexp -nocase "^To unite all people within our nation!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != $nick} {
      putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
      return 0
    }
    if {$bMotionCache(teamRocket) == ""} {
      return 0
    }
    bMotionDoAction $channel $nick "to denounce the evil of truth and love"
    return 0
  }

  if [regexp -nocase "^to denounce the evils? of truth and love!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != $nick} {
      putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
      return 0
    }
    if {$bMotionCache(teamRocket) == ""} {
      return 0
    }
    bMotionDoAction $channel $nick "to extend our reach to the stars above"
    return 0
  }

  if [regexp -nocase "^to extend our reach to the stars above!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != $nick} {
      putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
      return 0
    }
    if {$bMotionCache(teamRocket) == ""} {
      return 0
    }
    bMotionDoAction $channel $nick "Jessie"
    return 0
  }

  if [regexp -nocase "^(jessie|$nick)!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != $nick} {
      return 0
    }
    if {$bMotionCache(teamRocket) == ""} {
      return 0
    }
    bMotionDoAction $channel $nick "Jame.. er, $botnick"
    return 0
  }

  if [regexp -nocase "^team rocket blast off at the speed of light!?$" $text] {
    if {$bMotionInfo(balefire) != 1} { return 0 }
    if {$bMotionCache(teamRocket) != $nick} {
      putserv "NOTICE $nick :Sorry, I'm already performing the Team Rocket chant with $bMotionCache(teamRocket)"
    }
    if {$bMotionCache(teamRocket) == ""} {
      return 0
    }
    bMotionDoAction $channel $nick "Surrender now or prepare to fight!"
    set bMotionCache(teamRocket) ""
    return 0
  }
  ## /team rocket

  if [regexp -nocase "^${botnicks}(:?) (wins|exactly|precisely|perfect|nice one)\.?!?$" $text] {
    global harhars
    bMotionDoAction $channel $nick [pickRandom $harhars]
    bMotionGetHappy
    bMotionGetUnLonely
    driftFriendship $nick 1
    return 0
  }

  if [regexp -nocase "^(well done|good(work|show)),? ${botnicks}\.?$" $text] {
    bMotionDoAction $channel $nick "%VAR{harhars}"
    bMotionGetHappy
    bMotionGetUnLonely
    driftFriendship $nick 1
    return 0
  }

  if [regexp -nocase "^hn{3,}$" $text] {
    global botnick blindings
	  if [rand 2] {return 0}
    bMotionDoAction $channel "" [pickRandom $blindings]
  }

  if [regexp -nocase "^zzz+$" $text] {
    if [rand 2] {
      global handcoffees
      bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $handcoffees]
    }
  }

  ## This is the clever bit. If the text is "*blah blah blah*" reinject it into bMotion as an action ##
  if [regexp {^\*(.+)\*$} $text blah action] {
    bMotion_putloglev 1 * "Unhandled *$action* by $nick in $channel... redirecting to action handler"
    bMotion_event_action $nick $host $handle $channel "" $action
    return 0
  }

}
## END main events



## BEGIN action event handler
proc bMotion_event_action {nick host handle dest keyword text} {

  global botnick mood rarrs smiles unsmiles botnicks bMotionCache bMotionSettings bMotionInfo
  set dest [channame2dname $dest]
  set channel $dest

  if [matchattr $handle J] {
    return 0
  }

  #ignore other bots
  if {[matchattr $handle b]} {
    return 0
  }

  if {[lsearch $bMotionInfo(randomChannels) [string tolower $channel]] == -1} {
    return 0
  }

  bMotion_putloglev 4 * "bMotion: entering bMotion_event_action with $nick $host $handle $dest $keyword $text"


  set nick [bMotion_cleanNick $nick $handle]

  ## Trim ##
  set text [string trim $text]

  ## Dump double+ spaces ##
  regsub -all "  +" $text " " text

  #ignore lines with <nobotnick> tags
  if [regexp -nocase "\</?no$botnicks\>" $text] {return 0}
  if [regexp -nocase "\<no$botnicks\>" $text] {return 0}

  #check for someone breaking the loop of lastSpoke
  if [regexp -nocase "${botnicks}:? (i'm not talking to|not) you" $text] {
    bMotionDoAction $channel $nick "oh"
    set bMotionCache($channel,last) 0
  }

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
  }

  ## Run the simple plugins ##
  set response [bMotion_plugin_find_action_simple $text $bMotionInfo(language)]
  if {$response != ""} {
    bMotion_putloglev 1 * "bMotion: matched simple action plugin, outputting $response..."
    set nick [bMotionGetRealName $nick $host]
    bMotionDoAction $channel $nick [pickRandom $response]
    return 0
  }

  ## Run the complex plugins ##
  set response [bMotion_plugin_find_action_complex $text $bMotionInfo(language)]
  if {[llength $response] > 0} {
    #set nick [bMotionGetRealName $nick $host]
    foreach callback $response {
      bMotion_putloglev 1 * "bMotion: matched complex action plugin, running callback $callback"
      set result [$callback $nick $host $handle $channel $text]
      if {$result == 1} {
        break
      }
    }
    return 0
  }

  ## LEGACY CODE STARTS HERE

	if [regexp -nocase "((s(e|3)x(o|0)r(s|z|5))|(fluffles)|fucks|paalt|shags|paalt|fondles|ravages|rapes|spanks|kisses|zoent) $botnicks" $text] {
    if [regexp -nocase "(ass|arse|bottom|anal|rape(s)?|fist)" $text] {
      driftFriendship $nick -5
      frightened $nick $dest
      return 0
    }
    if [bMotionLike $nick $host] {
      driftFriendship $nick 4
      bMotionDoAction $dest "" [pickRandom $rarrs]
      incr mood(horny) 2
      incr mood(happy)
      set mood(lonely) [expr $mood(lonely) - 1]
      checkmood $nick $dest
    } else {
      frightened $nick $dest
      driftFriendship $nick -1
    }
		return 0
	}

  #parks/puts
  if [regexp -nocase "(parks|puts|places|inserts|shoves|sticks) (his|her|a|the|some) (.+) (in|on|up) $botnicks" $text ming verb other item] {
    #is it someone we like?
    if {![bMotionLike $nick $host]} {
      global parkedinsDislike
      bMotionDoAction $channel $nick [pickRandom $parkedinsDislike]
      bMotionGetSad
      bMotionGetUnLonely
      driftFriendship $nick -1
      return 0
    }

    bMotionGetHorny
    bMotionGetHappy
    bMotionGetUnLonely
    global rarrs lovesits
    set responses $rarrs
    set responses [concat $responses $lovesits]
    bMotionDoAction $channel $nick [pickRandom $responses]
    return 0
  }


  if [regexp -nocase "balefires (.+)" $text ming who] {
    global bMotionInfo
    if [regexp -nocase $botnicks $who] {
      global balefired
      bMotionDoAction $dest $nick [pickRandom $balefired]
      incr mood(lonely) -1
      incr mood(happy) -1
      driftFriendship $nick -1
    } else {
      if {![onchan $who $dest]} { return 0 }
      if {$bMotionInfo(balefire) != 1} { return 0 }
      putserv "PRIVMSG $who :Sorry, you stopped existing a few minutes ago. Please sit down and be quiet until you are woven into the pattern again."
    }
    return 0
  }

  if [regexp -nocase "makes $botnicks (.+)" $text ming ming2 details] {
    global mood bMotionInfo
    if {![bMotionLike $nick $host]} {
      frightened $nick $dest
      return 0
    }
    if [regexp -nocase "(come|cum)" $details] {
      if {![bMotionLike $nick $host]} {
        frightened $nick $dest
        driftFriendship $nick -2
        return 0
      }
      if {$bMotionInfo(gender) == "male"} {
        bMotionDoAction $dest $nick "/cums over %%"
        bMotionDoAction $dest $nick "ahhh... thanks, I needed that"
        incr mood(happy) 2
        incr mood(horny) -1
        driftFriendship $nick 2
        return 0
      }
      bMotionDoAction $dest $nick "~oof~ :D"
      incr mood(happy) 2
      incr mood(horny) -1
      driftFriendship $nick 2
    }
  }

  if [regexp -nocase "(kicks|smacks|twats|injures|beats up|punches|hits|thwaps|slaps|pokes|kills|destroys) ${botnicks}" $text] {
    global mood
    incr mood(happy) -1
    incr mood(lonely) -1
    driftFriendship $nick -2
    if [rand 2] {
      frightened $nick $dest
      return 0
    }
    bMotionDoAction $dest $nick "/smacks %% back with %VAR{sillyThings}"
    set bMotionCache(lastEvil) $nick
    return 0
  }

  ## KatieStar ;)

  if [string match -nocase "anal sex" $text] {
    if [bMotionLike $nick $host] {
      global analsexhelps
      if [rand 2] {
        bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $analsexhelps]
      }
    }
    return 0
  }

  if [string match -nocase "wank" $text] {
    if [bMotionLike $nick $host] {
      global wankhelps
      if [rand 2] {
        bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $wankhelps]
      }

    }
    return 0
  }


  #if [regexp -nocase "(steals|pinches|theives|removes) ${botnicks}'?s (.+)" $text ming action object] {
  #  # TODO: check $object and $action (e.g. pinches arse)
  #  global stolens
  #  bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $stolens]
  #  bMotionGetSad
  #  set bMotionCache(lastEvil) $nick
  #  driftFriendship $nick -1
  #  return 0
  #}

  ## bites
  #if [regexp -nocase "(bites|licks) $botnicks" $text] {
  #  global lovesits
  #  if [bMotionLike $nick $host] {
  #    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $lovesits]
  #    bMotionGetHorny
  #    bMotionGetHappy
  #    driftFriendship $nick 1
  #  } else {
  #    frightened $nick $dest
  #    driftFriendship $nick -1
  #  }
  #  return 0
  #}

  ## snickers
  if [regexp -nocase "^snicker(s)?" $text ming pop] {
    global chocolates
    if [rand 2] {
      set response [pickRandom $chocolates]
      set response "/$response$pop"
      bMotionDoAction $channel $nick $response
    }
    return 0
  }

  ##hide behind
  if [regexp -nocase "hides behind $botnicks" $text] {
    global hiddenBehinds
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $hiddenBehinds]
    bMotionGetUnLonely
    bMotionGetHappy
    return 0
  }

  ##sat on
  if [regexp -nocase "sits on $botnicks" $text] {
    global satOns
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $satOns]
    bMotionGetSad
    bMotionGetUnLonely
    driftFriendship $nick -1
    return 0
  }

  ## hops into lap
  if [regexp -nocase "hops (in|on)to ${botnicks}'?s lap" $text] {
    global rarrs
    if [bMotionLike $nick $host] {
      bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $rarrs]
      bMotionGetHorny
      bMotionGetHappy
      bMotionGetUnLonely
      driftFriendship $nick 1
    } else {
      frightened $nick $channel
      driftFriendship $nick -1
    }
    return 0
  }

  if [regexp -nocase "^(falls asleep on|dozes off on|snoozes on|sleeps on) $botnicks" $text] {
    if [bMotionLike $nick $host] {
      global rarrs
      bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $rarrs]
      bMotionGetHorny
      bMotionGetHappy
      bMotionGetUnLonely
      driftFriendship $nick 1
    } else {
      frightened $nick $channel
      bMotionGetUnHappy
      driftFriendship $nick -1
    }
    return 0
  }

  ##throws bot at
  if [regexp -nocase "(throws|chucks|lobs|fires|launches|ejects|pushes) $botnicks (at|to|though|out of|out|off|into) (.+)" $text matches verb botn pop target] {
    if [regexp -nocase "^${botnicks}$" $target] {
      bMotionDoAction $channel "" "hmm"
      return 0
    }
    global thrownAts
    bMotionDoAction $channel $target [pickRandom $thrownAts]
    bMotionGetUnLonely
    driftFriendship $nick -1
    return 0
  }
}

### MODE HANDLER #############################################################
proc bMotion_event_mode {nick host handle channel mode victim} {

  bMotion_putloglev 4 * "bMotion: entering bMotion_event_mode with $nick $host $handle $channel $mode $victim"

  global botnick
	if {$victim != $botnick} {return 0}

	if {$mode == "+o"} {
	  if {$nick == ""} {return 0}

    #check to see if i was opped before
    if [wasop $botnick $channel] { return 0 }

	  bMotionDoAction $channel "" "%VAR{thanks}"
		return 0
  }

	if {$mode == "-o"} {
	  bMotionDoAction $channel "" "hey! %VAR{unsmiles} i needed that"
		return 0
  }
}


#someone changed nick, check for an away "msg"
proc bMotion_event_nick { nick host handle channel newnick } {
  if [matchattr $handle J] {
    return 0
  }

  set nick [bMotion_cleanNick $nick $handle]
  set newnick [bMotion_cleanNick $newnick $handle]

  set result [bMotionDoEventResponse "nick" $nick $host $handle $channel $newnick ]
}
#end of nick handler


bMotion_putloglev d * "bMotion: events module loaded"
