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

# register our counters
bMotion_counter_init "events" "simpleplugins"
bMotion_counter_init "events" "complexplugins"
bMotion_counter_init "events" "lines"

# call an irc event response plugin
proc bMotionDoEventResponse { type nick host handle channel text } {
  #check our global toggle
  global bMotionGlobal bMotionInfo
  if {$bMotionGlobal == 0} {
    return 0
  }

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

  #check our global toggle
  global bMotionGlobal
  if {$bMotionGlobal == 0} {
    return 0
  }

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

  #check our global toggle
  global bMotionGlobal
  if {$bMotionGlobal == 0} {
    return 0
  }

  set nick [bMotion_cleanNick $nick $handle]

  set bMotionCache(lastLeft) $nick

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
  #check our global toggle
  global bMotionGlobal
  if {$bMotionGlobal == 0} {
    return 0
  }

  ## Global definitions ##
  global mood botnick
  global bMotionLastEvent bMotionSettings botnicks bMotionCache bMotionInfo
  global bMotionThisText bMotionOriginalInput bMotionOriginalNick

  if [matchattr $handle J] {
    return 0
  }

  set bMotionOriginalNick $nick

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

  set bMotionOriginalInput $text

  #filter bold, etc codes out
  regsub -all "\002" $text "" text
  regsub -all "\022" $text "" text
  regsub -all "\037" $text "" text
  regsub -all "\003\[0-9\]+(,\[0-9+\])?" $text "" text
  
  #try stripcodes (eggdrop 1.6.17+)
  catch {
  	set text [stripcodes $text]
  }

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
  }

  #does this look like a paste?
  if [regexp -nocase {^[0-9\[<(@+%]} $text] {
    return 0
  }

  ## Update the channel idle tracker ##
  set bMotionLastEvent($channel) [clock seconds]

  bMotion_counter_incr "events" "lines"

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
    regsub -all {([\-^])_*[\-^];*} $text "" text
  }

  ## Trim ##
  set text [string trim $text]

  ## Dump double+ spaces #
  regsub -all "  +" $text " " text

  ## Update the last-talked flag for the join system
  bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 0

  set bMotionThisText $text

  #if we spoke last, add "$botnick: " if it's not in the line
  if {![regexp -nocase $botnicks $text] && ($bMotionCache($channel,last) || [bMotion_setting_get "bitlbee"])} {
    set text "${botnick}: $text"
  }

  if [bMotion_setting_get "bitlbee"] {
    bMotion_putloglev d * "bitlbee incoming from $nick: $text"
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
    bMotion_counter_incr "events" "simpleplugins"
    bMotionDoAction $channel $nick [pickRandom $response]
    return 0
  }

  ## Run the complex plugins ##
  set response [bMotion_plugin_find_complex $text $bMotionInfo(language)]
  if {[llength $response] > 0} {
    #set nick [bMotionGetRealName $nick $host]
    bMotion_putloglev 1 * "going to run plugins: $response"
    foreach callback $response {
      bMotion_flood_add $nick $callback $text
      if [bMotion_flood_check $nick] { return 0 }

      bMotion_putloglev 1 * "bMotion: `- running callback $callback"
      bMotion_counter_incr "events" "complexplugins"
      set result [$callback $nick $host $handle $channel $text]
      set bMotionCache(lastPlugin) $callback
      if {$result == 1} {
        bMotion_putloglev 2 * "bMotion:    `-$callback returned 1, breaking out..."
        break
      }
    }
  }


  #Check for all caps
  regsub -all {[^A-Za-z]} $text "" textChars
  regsub -all {[a-z]} $textChars "" textLowerChars
  if {(([string length $textChars] > 4) && ([expr [string length $textLowerChars] / [string length $textChars]] > 0.9)) ||
        [regexp ".+!{4,}" $text]} {
    global blownAways
    if {[rand 60] >= 55} {
      bMotionDoAction $channel $nick "%VAR{blownAways}"
      return 0
    }
  }

  ################################# Things that can be responded to from everyone ##########################

  ## Reload config files
  ## Requires global +m
  if [regexp -nocase "${botnicks},?:? re(hash|load)( your config files?)?" $text] {
    putlog "bMotion: $nick asked me to rehash in $channel"
    global bMotionCache bMotion_testing bMotionRoot

    if [matchattr $handle m] {
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
    } else {
      bMotionDoAction $channel $nick "I think not."
      return 0
    }
  }
  ## /Reload config files

  ####whole-line matches

  ## tell the names we have
  if [regexp -nocase "${botnicks}:?,? say my names?(,? bitch)?" $text] {
  	if {($handle == "*") || ($handle == "")}  {
  		#no handle = no saving IRL
  		 bMotionDoAction $channel $nick "%%: Sorry, you aren't in my userfile so I can't store an IRL name for you."
  		 return 0
  	}
  	
    set realnames [getuser $handle XTRA irl]
    if {$realnames == ""} {
      bMotionDoAction $channel $nick "Ah you must be %%. (You have not set any IRL names.)" "" 1
    } else {
      bMotionDoAction $channel $nick "Your IRL name(s) are:\002 %2 \002" $realnames 1
    }
    puthelp "NOTICE $nick :To update your IRL names, do \002/msg $botnick IRL name1 name2 name3 ...\002"
    return 0
  }

  ###################################### +I people only ###################################################

  if {$bMotionSettings(needI) == 1} {
    if {![matchattr $handle I]} {return 0}
  }

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

  #check our global toggle
  global bMotionGlobal
  if {$bMotionGlobal == 0} {
    return 0
  }

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

#end of action handler
}

### MODE HANDLER #############################################################
proc bMotion_event_mode {nick host handle channel mode victim} {

  #check our global toggle
  global bMotionGlobal
  if {$bMotionGlobal == 0} {
    return 0
  }

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

  #check our global toggle
  global bMotionGlobal
  if {$bMotionGlobal == 0} {
    return 0
  }

  if [matchattr $handle J] {
    return 0
  }

  set nick [bMotion_cleanNick $nick $handle]
  set newnick [bMotion_cleanNick $newnick $handle]

  set result [bMotionDoEventResponse "nick" $nick $host $handle $channel $newnick ]
}
#end of nick handler


bMotion_putloglev d * "bMotion: events module loaded"
