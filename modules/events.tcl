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

## BEGIN onjoin handler
proc bMotion_event_onjoin {nick host handle channel} {
  global bMotionCache welcomeBacks

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

  global ranjoins bigranjoins botnick mood
  set chance [rand 10]
  set greetings $ranjoins
  if {$chance > 8} {
    if [matchattr $handle I] {
      set greetings [concat $greetings $bigranjoins]
      if {$nick == $bMotionCache(lastLeft)} {
        set greetings $welcomeBacks
        set bMotionCache(lastLeft) ""
      }
      incr mood(happy)
      incr mood(lonely) -1
    }

    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $greetings]
    set bMotionCache(lastGreeted) $nick
  }
}
## END onjoin


## BEGIN onpart handler
proc bMotion_event_onpart {nick uhost hand chan {msg ""}} {
  global bMotionCache
  set bMotionCache(lastLeft) $nick
}
## END onpart


## BEGIN onquit handler
proc bMotion_event_onquit {nick host handle channel reason} {
  global bMotionCache bMotionSettings bMotionInfo

  if {$bMotionSettings(needI) == 1} {
    set bMotionCache(lastLeft) $nick
  }

  if {$bMotionInfo(brig) == ""} { return 0 }

  #check if that person was in the brig
  regexp -nocase "(.+)@(.+)" $bMotionInfo(brig) pop brigNick brigChannel
  if [string match -nocase $nick $brigNick] {
    set bMotionInfo(brig) ""
    bMotionDoAction $brigChannel "" "Curses! They escaped from the brig."
  }
}
## END onquit

# BEGIN main interactive
proc bMotion_event_main {nick host handle channel text} {

  bMotion_putloglev 4 * "bMotion: entering bMotion_event_main with $nick $host $handle $channel $text"

  if [matchattr $handle J] {
    return 0
  }

  #remove []s and \s from nick cos they break things (Minder[]...)
  if [regexp {[\\\[\]]} $nick] {
    if {$handle != ""} {
      set nick $handle
    } else {
      regsub -all {[\\\[\]]} $nick "" nick
    }
  }
  #regsub -all {(\[|\])} $nick "" nick

  ## Global definitions ##
  global mood botnick greetings welcomes sorryoks
  global loveresponses boreds upyourbums smiles
  global arrs botnick arrcachenick arrcachearr
  global bMotionLastEvent bMotionSettings botnicks bMotionCache bMotionInfo
  global bMotionThisText  

  if {[lsearch $bMotionInfo(randomChannels) [string tolower $channel]] == -1} {
    return 0
  }

  #filter bold codes out
  regsub -all "\002" $text "" text
  regsub -all "\022" $text "" text
  regsub -all "\037" $text "" text
  regsub -all {\003[0-9]+(,[0-9+])?} $text "" text

  #first, check botnicks (this is to get round empty-nick-on-startup
  if {$botnicks == ""} {
    # need to set this
    set botnicks "($botnick|$bMotionSettings(botnicks)) ?"
  }

  ## Update the channel idle tracker ##
  set bMotionOldIdle 0
  catch {
    set bMotionOldIdle [expr [clock seconds] - $bMotionLastEvent($channel)]
  }
  set bMotionLastEvent($channel) [clock seconds]
  
  #ignore other bots
  if {[matchattr $handle b]} {
    set bMotionCache($channel,last) 0
    return 0
  }

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

  ## Trim ##
  set text [string trim $text]

  ## Dump double+ spaces ##
  regsub -all "  +" $text " " text

  set bMotionThisText $text

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
      if {$result == 1} {
        bMotion_putloglev 2 * "bMotion: $callback returned 1, breaking out..."
        break
      }
    }
    return 0
  }

  #if we spoke last, add "$botnick: " if it's not in the line
  if {![regexp -nocase $botnicks $text] && $bMotionCache($channel,last)} {
    set text "${botnick}: $text"
  }

  #check for someone breaking the loop of lastSpoke
  if [regexp -nocase "${botnicks}:? (i'm not talking to|not) you" $text] {
    bMotionDoAction $channel $nick "oh"
    set bMotionCache($channel,last) 0
  }
  set bMotionCache($channel,last) 0

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
    global randomsinfo cvsinfo
    bMotionDoAction $channel $nick "I'm running bMotion $cvsinfo (randoms file $randomsinfo)"
    return 0
  }

  #check for a smiley
  global bMotionCache
  if [regexp {[8|:|;|=][-|o|O]?([\)D\(C])} $text bling mouth] {
    if {$mouth == ")"} {
      incr bMotionCache($channel,mood) 5
    }
    if {$mouth == "D"} {
      incr bMotionCache($channel,mood) 7
    }

    if {$mouth == "("} {
      incr bMotionCache($channel,mood) -5
    }
    if {$mouth == "C"} {
      incr bMotionCache($channel,mood) -7
    }
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

  ##opme --> kick ;) (now a complex plugin)


  ##url (now a simple plugin)

  ## ali g (now a simple plugin)

  ## wassssup (now a simple plugin)
     
  ## oops (now a simple plugin)

  ## shock (now a simple plugin)

  ## bof (now a simple plugin)

  ## alors (now a simple plugin)

  ## moo
  ## --> moo (now a simple plugin)
  
  ## eat
  ## --> /me eats ...
  ## --> go down on
  ## /eat

  ## go down on
  ## --> go down on

  ## hello  
  ## --> hello back
  ## /hello

  ## watch out
  ## --> eek|hide|runs

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

  ##thank you
  ## --> you're welcome


  ## sorry
  ## --> that's ok

  ## welcome back
  ## --> thanks

  ##love
  ## /love

  ##uNF

  ##blblblbl
  ## /blblblbl

  ##bhar etc
  ## /bhar etc

  ## :)
  if {[regexp "^(((:|;|=)(\\\)|]|D))|hehe|heh|wheee+)$" $text]} {
	  if {$botnick == $nick} {return 0}
		if {$mood(happy) < 0} {
			return 0
		}

    global bMotionLastEvent
    if {($bMotionOldIdle > 300) || ($mood(lonely) < 1)} {
 			if {[rand 10] > 6} {
    	  bMotionDoAction $channel "" [pickRandom $smiles]
      }
	  }
    bMotionGetHappy
    bMotionGetUnLonely
		checkmood $nick $channel
		return 0
	}

  ## :( (now a simple plugin)

  ## replicate
  ## /replicate

  ## hand
  ## /hand

  ##supermarkets

  #hug

  ## readings

  ## transforms (now a simple plugin)

  ## all together
  #if [regexp -nocase "(.+) all together.?$" $text ming bhar] {
  #  #set bhar [string range $text 0 [expr [string first $text "all together"] - 2]]
  #  bMotionDoAction $channel [bMotionGetRealName $nick $host] "$bhar."
  #  return 0
  #}


  ## stupid bot(s)


  ## sneeze

  ## little bit

  ## is a bot

  ## are you a bot|is a bot?
 
  ## snickers

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

  #ouch (now a simple plugin)

  if [regexp -nocase {[[:<:]]a/?s/?l[[:>:]]} $text] {
    if {[bMotionTalkingToMe $text] || [rand 2]} {
      set age [expr [rand 20] + 13]
      global bMotionInfo
      bMotionDoAction $channel $nick "%%: $age/$bMotionInfo(gender)/%VAR{locations}"
      return 0
    }
  }

  ## What question targeted at me
  if { [regexp -nocase "^$botnicks,?:? what('?s)?(.+)" $text matches botn s question] ||
       [regexp -nocase "^what('?s)? .* $botnicks ?\\?" $text matches s question botn] } {
    bMotion_putloglev d * "bMotion: $nick asked me a what question"

    #see if we know the answer to it
    if {$question != ""} {
      if [regexp -nocase {[[:<:]]a/?s/?l[[:>:]]} $question] {
        set age [expr [rand 20] + 13]
        global bMotionInfo
        bMotionDoAction $channel $nick "%%: $age/$bMotionInfo(gender)/%VAR{locations}"
        return 0
      }
    }

    global answerWhats
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $answerWhats]
    return 0
  }

  ## With/at/against who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (with|at|against|by) who" $text ma mb prop] ||
       [regexp -nocase "^(with|at|against|by) who .* $botnicks ?\\?" $text ma prop ma] } {
    bMotion_putloglev d * "bMotion: $nick asked me a with/at/against who question ($prop)"
    global answerWithWhos
    set randomans [pickRandom $answerWithWhos]
    set answer "$prop $randomans"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] $answer
    return 0
  }

  ## Who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? who(se)? " $text matches bot owner] ||
       [regexp -nocase "^who(se)? .* $botnicks ?\\?" $text matches owner] } {
    bMotion_putloglev d * "bMotion: $nick asked me a who$owner question"
    
    if {$owner == "se"} {
      set line [bMotionMakePossessive [bMotionDoInterpolation "%VAR{answerWhos}" "" "" ""] 1]
    } else {
      set line "%VAR{answerWhos}"
    }
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "$line"
    return 0
  }

  ## Why question targeted at me
  if { [regexp -nocase "^$botnicks,?:? why" $text] ||
       [regexp -nocase "why.* $botnicks ?\\?" $text] } {
    bMotion_putloglev d * "bMotion: $nick asked me a why question"
    global answerWhys
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $answerWhys]
    return 0
  }

  ## Where question targeted at me
  if { [regexp -nocase "^$botnicks,?:? where" $text] ||
       [regexp -nocase "^where .* $botnicks ?\\?" $text] } {
    bMotion_putloglev d * "bMotion: $nick asked me a where question"
    global answerWheres
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $answerWheres]
    return 0
  }

  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?many" $text] ||
       [regexp -nocase "^how ?many .* $botnicks ?\\?" $text] } {
    bMotion_putloglev d * "bMotion: $nick asked me a how many question"
    global answerHowmanys
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $answerHowmanys]
    return 0
  }

  ## When question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (when|what time)" $text] ||
       [regexp -nocase "^(when|what time) .* $botnicks ?\\?" $text] } {
    bMotion_putloglev d * "bMotion: $nick asked me a when question"
    global answerWhens
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $answerWhens]
    return 0
  }

  ## How question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how" $text] ||
       [regexp -nocase "^how .* $botnicks ?\\?" $text] } {
    bMotion_putloglev d * "bMotion: $nick asked me a how question"
    global answerHows
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $answerHows]
    return 0
  }

  # me .... ?
  if [regexp -nocase "^${botnicks}:?,? (.+)\\?$" $text ming ming2 question] {
    global randomReplies
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $randomReplies]
    return 0
  }

  # ... me?
  if [regexp -nocase "${botnicks}\\?$" $text bhar ming what] {
    if { [rand 2] == 1 } {
      global randomReplies
      bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $randomReplies]
      return 0
    }
  }

  if [regexp -nocase "^hn{3,}$" $text] {
    global botnick blindings
	  if [rand 2] {return 0}
    bMotionDoAction $channel "" [pickRandom $blindings]
  }

  if [regexp -nocase {^[!\"£\$%\^&\*\(\)\@\#]{3,}} $text] {
    if [rand 2] {
      bMotionDoAction $channel $nick [bMotionGetColenChars]
    }
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

  bMotion_putloglev 4 * "bMotion: entering bMotion_event_action with $nick $host $handle $dest $keyword $text"

  global botnick mood rarrs smiles unsmiles botnicks bMotionCache bMotionSettings bMotionInfo
  set channel $dest

  if {[lsearch $bMotionInfo(randomChannels) [string tolower $channel]] == -1} {
    return 0
  }

  if [matchattr $handle J] {
    return 0
  }

  #ignore other bots
  if {[matchattr $handle b]} {
    return 0
  }

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
    global mood sillyThings
    incr mood(happy) -1
    incr mood(lonely) -1
    driftFriendship $nick -2
    if [rand 2] {
      frightened $nick $dest
      return 0
    }
    bMotionDoAction $dest $nick "/smacks %% back with [pickRandom $sillyThings]"
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


  if [regexp -nocase "(steals|pinches|theives|removes) ${botnicks}'?s (.+)" $text ming action object] {
    # TODO: check $object and $action (e.g. pinches arse)
    global stolens
    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $stolens]
    bMotionGetSad
    set bMotionCache(lastEvil) $nick
    driftFriendship $nick -1
    return 0
  }

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

  global bMotionInfo
  ## Run the nick action plugins ##
  set response [bMotion_plugin_find_nick_action $newnick $bMotionInfo(language)]
  if {[llength $response] > 0} {
    foreach callback $response {
      bMotion_flood_add $nick $callback $newnick
      if [bMotion_flood_check $nick] { return 0 }
   
      bMotion_putloglev 1 * "bMotion: matched nick change plugin, running callback $callback"
      set result [$callback $nick $host $handle $channel $newnick ]
      if {$result == 1} {
        bMotion_putloglev 2 * "bMotion: $callback returned 1, breaking out..."
        break
      }
    }
    return 0
  }

}
#end of nick handler


bMotion_putloglev d * "bMotion: events module loaded"
