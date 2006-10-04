#bMotion - Output functions
#
# $Id$
#
# vim: fdm=indent fdn=1

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

# init our counters
bMotion_counter_init "output" "lines"
bMotion_counter_init "output" "irclines"

set bMotion_output_delay 0

proc pickRandom { list } {
	bMotion_putloglev 5 * "pickRandom ($list)"
  return [lindex $list [rand [llength $list]]]
}

proc getPronoun {} {
	bMotion_putloglev 5 * "getPronoun"
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "himself" }
  if {$bMotionInfo(gender) == "female"} { return "herself" }
  return "itself"
}

proc getHisHers {} {
	bMotion_putloglev 5 * "getHisHers"
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "his" }
  if {$bMotionInfo(gender) == "female"} { return "hers" }
  return "its"
}

proc getHisHer {} {
	bMotion_putloglev 5 * "getHisHer"
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "his" }
  if {$bMotionInfo(gender) == "female"} { return "her" }
  return "it"
}


proc getHeShe {} {
	bMotion_putloglev 5 * "getHeShe"
  global bMotionInfo
  if {$bMotionInfo(gender) == "male"} { return "he" }
  if {$bMotionInfo(gender) == "female"} { return "she" }
  return "it"
}


proc mee {channel action {urgent 0} } {
	bMotion_putloglev 5 * "mee ($channel, $action, $urgent)"
  set channel [chandname2name $channel]
  if {$urgent} {
    bMotion_queue_add_now $channel "\001ACTION $action\001"
  } else {
    bMotion_queue_add $channel "\001ACTION $action\001"
  }
}


## bMotionDoAction ###########################################################
proc bMotionDoAction {channel nick text {moreText ""} {noTypo 0} {urgent 0} } {
  bMotion_putloglev 5 * "bMotionDoAction($channel,$nick,$text,$moreText,$noTypo)"
  global bMotionInfo bMotionCache bMotionOriginalInput
	global bMotion_output_delay

	set bMotion_output_delay 0

  set bMotionCache($channel,last) 1

  #check our global toggle
  global bMotionGlobal
  if {$bMotionGlobal == 0} {
    return 0
  }

  if [regexp "^\[#!\].+" $channel] {
    set channel [string tolower $channel]
		if {![channel get $channel bmotion]} {
      bMotion_putloglev d * "bMotion: aborting bMotionDoAction ... $channel not allowed"
      return 0
    }
  }

  if {$bMotionInfo(silence) == 1} { return 0 }
  catch {
    if {$bMotionInfo(adminSilence,$channel) == 1} { return 0 }
  }

  bMotion_counter_incr "output" "lines"

  switch [rand 3] {
    0 { }
    1 { set nick [string tolower $nick] }
    2 { set nick "[string range $nick 0 0][string tolower [string range $nick 1 end]]" }
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
			set origtext $text
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
			if {$text == $origtext} {
        putlog "bMotion ALERT! Bailed in bMotionDoAction with $text. Lost output."
        return 0
      }
    }
  }

  if {$multiPart == 1} {
    foreach lineIn $thingsToSay {
      set temp [bMotionSayLine $channel $nick $lineIn $moreText $noTypo $urgent]
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
      if [rand 2] {
        bMotionDoAction $channel "" "%VAR{typoFix}" "" 1
      }
      bMotion_plugins_settings_set "output:typos" "typos" "" "" ""


    }
    return 0
  }

  bMotionSayLine $channel $nick $text $moreText $noTypo $urgent
  set typosDone [bMotion_plugins_settings_get "output:typos" "typosDone" "" ""]
  bMotion_putloglev 2 * "bMotion: typosDone is !$typosDone!"
  if {$typosDone != ""} {
    bMotion_plugins_settings_set "output:typos" "typosDone" "" "" ""
    if [rand 2] {
      bMotionDoAction $channel "" "%VAR{typoFix}" "" 1
    }
    bMotion_plugins_settings_set "output:typos" "typos" "" "" ""
  }

  return 0
}

proc bMotionDoInterpolation { line nick moreText { channel "" } } {
  bMotion_putloglev 5 * "bMotionDoInterpolation: line = $line, nick = $nick, moreText = $moreText, channel = $channel"
  global botnick bMotionCache

  if [string match "*%noun*" $line] {
    set line [bMotionInsertString $line "%noun" "%VAR{sillyThings}"]
  }

  set loops 0
  bMotion_putloglev 4 * "doing VAR processing"
  while {[regexp -nocase {%VAR\{([^\}]+)\}(\{strip\})?} $line matches BOOM clean]} {
  	#putlog "var: clean = $clean"
    global $BOOM
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %VAR code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    #see if we have a new-style abstract available
    set newText [bMotion_abstract_get $BOOM]
    set replacement ""
    if {$newText == ""} {
			bMotion_putloglev d * "abstract '$BOOM' doesn't exist in new abstracts system!"
      #insert old style
      set var [subst $$BOOM]
      set replacement [pickRandom $var]
    } else {
    	set replacement $newText
    }
    if {$clean != ""} {
    	set replacement [bMotion_strip_article $replacement]
    }
    regsub -nocase "%VAR\{$BOOM\}$clean" $line $replacement line
    if [string match "*%noun*" $line] {
      set line [bMotionInsertString $line "%noun" "%VAR{sillyThings}"]
    }
  }

  set loops 0
  bMotion_putloglev 4 * "doing SETTING processing"
  while {[regexp "%SETTING\{(.+?)\}" $line matches settingString]} {
    set var ""
    if [regexp {([^:]+:[^:]+):([^:]+):([^:]+):([^:]+)} $settingString matches plugin setting ch ni] {
      set var [bMotion_plugins_settings_get $plugin $setting $ch $ni]
    }
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %SETTING code with $line"
      set line "/has a tremendous error while trying to infer the meaning of life :("
    }
    if {$var == ""} {
      putlog "bMotion: ALERT! couldn't find setting $settingString (dropping output)"
      return ""
    }
    set line [bMotionInsertString $line "%SETTING{$settingString}" $var]
  }

  set loops 0
  bMotion_putloglev 4 * "doing NUMBER processing"
	set padding 0
  while {[regexp "%NUMBER\{(\[0-9\]+)\}(\{(\[0-9\]+)\})?" $line matches numberString paddingOpt padding]} {
    set var [bMotion_get_number [bMotion_rand_nonzero $numberString]]
		if {$padding > 0} {
			set fmt "%0$padding"
			append fmt "u"
			set var [format $fmt $var]
		}
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %NUMBER code with $line"
      set line "/has a tremendous error while trying to think of a number :("
    }
    set line [bMotionInsertString $line "%NUMBER\\{$numberString\\}(\\{\[0-9\]+\\})?" $var]
		set padding 0
  }

	set loops 0
	bMotion_putloglev 4 * "doing TIME processing"
	while {[regexp "%TIME\{(\[a-zA-Z0-9 \]+)\}" $line matches timeString]} {
		bMotion_putloglev 2 * "found timestring $timeString"
		set var [clock scan $timeString]
		set var [clock format $var -format "%I:%M %p"]
		bMotion_putloglev 2 * "using time $var"
		incr loops
		if {$loops > 10} {
			putlog "bMotion: ALERT! looping too much in %TIME code with %line"
			set line "/has a tremendous error while trying to do complex time mathematics :("
		}
		set line [bMotionInsertString $line "%TIME\\{$timeString\\}" $var]
	}

  bMotion_putloglev 4 * "doing misc interpolation processing for $line"
  set line [bMotionInsertString $line "%%" $nick]
  set line [bMotionInsertString $line "%pronoun" [getPronoun]]
  set line [bMotionInsertString $line "%himherself" [getPronoun]]
  set line [bMotionInsertString $line "%me" $botnick]
  set line [bMotionInsertString $line "%colen" [bMotionGetColenChars]]
  set line [bMotionInsertString $line "%hishers" [getHisHers]]
  set line [bMotionInsertString $line "%heshe" [getHeShe]]
  set line [bMotionInsertString $line "%hisher" [getHisHer]]
  set line [bMotionInsertString $line "%2" $moreText]
  set line [bMotionInsertString $line "%percent" "%"]
	

	bMotion_putloglev 4 * "done misc"

  #ruser:
  set loops 0
  while {[regexp "%ruser(\{(\[^\}\]+)\})?" $line matches param condition]} {
    set ruser [bMotionGetRealName [bMotion_choose_random_user $channel 0 $condition] ""]
    if {$condition == ""} {
      set findString "%ruser"
    } else {
      set findString "%ruser$param"
    }
    regsub $findString $line $ruser line
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %ruser code with $line"
      return ""
    }
  }

  #rbot:
  set loops 0
  while {[regexp "%rbot(\{(\[^\}\]+)\})?" $line matches param condition]} {
    set ruser [bMotionGetRealName [bMotion_choose_random_user $channel 1 $condition] ""]
    if {$condition == ""} {
      set findString "%rbot"
    } else {
      set findString "%rbot$param"
    }
    regsub $findString $line $ruser line
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %rbot code with $line"
      return ""
    }
  }

  bMotion_putloglev 4 * "bMotionDoInterpolation returning: $line"
  return $line
}

proc bMotionInterpolation2 { line } {
	bMotion_putloglev 5 * "bMotionInterpolation2 ($line)"
  #owners
  set loops 0
  while {[regexp -nocase "%OWNER\{(.*?)\}" $line matches BOOM]} {
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %OWNER code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    # set line [bMotionInsertString $line "%OWNER\{$BOOM\}" [bMotionMakePossessive $BOOM]]
    regsub -nocase "%OWNER\{$BOOM\}" $line [bMotionMakePossessive $BOOM] line
  }

  set loops 0
  while {[regexp -nocase "%VERB\{(.*?)\}" $line matches BOOM]} {
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %VERB code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    # set line [bMotionInsertString $line "%VERB\{$BOOM\}" [bMotionMakeVerb $BOOM]]
    regsub -nocase "%VERB\{$BOOM\}" $line [bMotionMakeVerb $BOOM] line
  }

  set loops 0
  while {[regexp -nocase "%PLURAL\{(.*?)\}" $line matches BOOM]} {
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %PLURAL code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    # set line [bMotionInsertString $line "%PLURAL\{$BOOM\}" [bMotionMakePlural $BOOM]]
    regsub -nocase "%PLURAL\{$BOOM\}" $line [bMotionMakePlural $BOOM] line
  }

  set loops 0
  while {[regexp -nocase "%REPEAT\{(.+?)\}" $line matches BOOM]} {
    incr loops
    if {$loops > 10} {
      putlog "bMotion: ALERT! looping too much in %REPEAT code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    # set line [bMotionInsertString $line "%REPEAT\\\{$BOOM\\\}" [bMotionMakeRepeat $BOOM]]
		set replacement [bMotionMakeRepeat $BOOM]
    regsub -nocase "%REPEAT\\{$BOOM\\}" $line $replacement line
  }

  return $line
}

proc bMotionSayLine {channel nick line {moreText ""} {noTypo 0} {urgent 0} } {
  bMotion_putloglev 5 * "bMotionSayLine: channel = $channel, nick = $nick, line = $line, moreText = $moreText, noTypo = $noTypo"
  global mood botnick bMotionInfo bMotionCache bMotionOriginalInput
	global bMotion_output_delay

  set line [bMotionInterpolation2 $line]

  #TODO: Put %ruser and %rbot back in here

  #if it's a bot , put it on the queue on the remote bot
  if [regexp -nocase {%(BOT)\[(.+?)\]} $line matches botcmd cmd] {
    set condition ""
    set dobreak 0
    if {$botcmd == "bot"} {
      #random
      bMotion_putloglev 1 * "bMotion: %bot detected"
      regexp {%bot\[([[:digit:]]+),(@[^,]+,)?(.+)\]} $line matches chance condition cmd
      bMotion_putloglev 1 * "bMotion: %bot chance is $chance"
      set dobreak 1
      if {[rand 100] < $chance} {
        set line "%BOT\[$cmd\]"
        set dobreak 0
      } else {
        set line ""
      }
    } else {
      #non-random
      regexp {%BOT\[(@[^,]+,)?(.+)\]} $line matches condition cmd
    }

    if {($condition != "") && [regexp {^@(.+),$} $condition matches c]} {
      set condition $c
    } else {
      if {$condition != ""} {
        set cmd $condition
        set condition ""
      }
    }

    if {$line != ""} {
      set bot [bMotion_choose_random_user $channel 1 $condition]
      bMotion_putloglev 1 * "bMotion: queuing botcommand !$cmd! for output to $bot"
      bMotion_queue_add $channel "@${bot}@$cmd"
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

  if [regexp {%DELAY\{([0-9]+)\}} $line matches delay] {
	    set bMotion_output_delay $delay
			    bMotion_putloglev d * "Changing output delay to $delay"
					set line ""
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

  #make sure the line wasn't set to blank by a plugin (may be trying to block output)
  if {($line == "") || [regexp "^ +$" $line]} {
    return 0
  }

	if {[string index $line end] == " "} {
		set line [string range $line 0 end-1]
	}

  #check if this line matches the last line said on IRC
  global bMotionThisText
  if [string match -nocase $bMotionThisText $line] {
    bMotion_putloglev 1 * "bMotion: my output matches the trigger, dropping"
    return 0
  }
	
	#protect this block - it'll generate an error if noone's talked yet, and then
	#we try an admin plugin
	if [info exists bMotionOriginalInput] {
		if [string match -nocase $bMotionOriginalInput $line] {
			bMotion_putloglev 1 * "my output matches the trigger, dropping"
			return 0
		}
	}

  set line [bMotionInsertString $line "%slash" "/"]

	global bMotion_output_delay

  if [regexp "^/" $line] {
    #it's an action
    mee $channel [string range $line 1 end] $urgent
  } else {
    if {$urgent} {
      bMotion_queue_add_now [chandname2name $channel] $line
    } else {
      bMotion_queue_add [chandname2name $channel] $line $bMotion_output_delay
    }
  }
  return 0
}

proc bMotionInsertString {line swapout toInsert} {
	bMotion_putloglev 5 * "bMotionInsertString ($line, $swapout, $toInsert)"
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
	bMotion_putloglev 5 * "bMotionGetColenChars"
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
	bMotion_putloglev 5 * "makeSmiley"
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
	bMotion_putloglev 5 * "bMotionWashNick ($nick)"
  #remove leading
  regsub {^[|`_\[]+} $nick "" nick

  #remove trailing
  regsub {[|`_\[]+$} $nick "" nick

  return $nick
}

proc OLDbMotionGetRealName { nick { host "" }} {
  bMotion_putloglev 5 * "bMotion: OLDbMotionGetRealName($nick,$host)"

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

proc bMotionGetRealName { nick { host "" }} {
  bMotion_putloglev 5 * "bMotion: bMotionGetRealName($nick,$host)"

  if {$nick == ""} {
    return ""
  }

  #is it me?
  if [isbotnick $nick] {
    return "me"
  }

  if [validuser $nick] {
    #it's a handle already
    set handle $nick
  } else {
    #try to figure it out
    set handle [nick2hand $nick]
    if {($handle == "") ||($handle == "*")} {
      #not in bot
      bMotion_putloglev 2 * "bMotion: no match, using nick"
      return $nick
    }
  }

  bMotion_putloglev 2 * "bMotion: $nick is handle $handle"

  # found a user, now get their real name
  set realname [getuser $handle XTRA irl]
  if {$realname == ""} {
    #not set
    bMotion_putloglev 2 * "no IRL set, using nick"
    return $nick
  }
  putloglev 2 * "bMotion: IRLs for $handle are $realname"
  return [pickRandom $realname]
}

proc bMotionTransformNick { target nick {host ""} } {
	bMotion_putloglev 5 * "bMotionTransformNick($target, $nick, $host)"
  set newTarget [bMotionTransformTarget $target $host]
  if {$newTarget == "me"} {
    set newTarget $nick
  }
  return $newTarget
}

proc bMotionTransformTarget { target {host ""} } {
	bMotion_putloglev 5 * "bMotionTransformTarget($target, $host)"
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

# bMotion_choose_random_user
#
# selects a random user or bot from a channel
# bot = 0 if you want a user, = 1 if you want a bot
# condition is one of:
#   * "" - anyone
#   * male, female - pick by gender
#   * like, dislike - pick by if we'd do them
#   * friend, enemy - pick by if we're friends
#   * prev - return previously chosen user/bot
proc bMotion_choose_random_user { channel bot condition } {
	bMotion_putloglev 5 * "bMotion_choose_random_user ($channel, $bot, $condition)"
  global bMotionCache
  set users [chanlist $channel]
  set acceptable [list]

  #check if we want the previous ruser
  if {$condition == "prev"} {
    set what [list "" ""]
    catch {
      set what [array get bMotionCache "lastruser$bot"]
    }
    bMotion_putloglev 4 * "accept: prev ($what)"
    return [lindex $what 1]
  }

  foreach user $users {
    bMotion_putloglev 4 * "eval user $user"
    #is it me?
    if [isbotnick $user] { continue }

    if {[bMotion_setting_get "bitlbee"] && ($user == "root")} {
      bMotion_putloglev 4 * "  --reject: bitlbee root user"
      continue
    }

    #get their handle
    set handle [nick2hand $user $channel]
    bMotion_putloglev 4 * "  handle: $handle"

    #unless we're looking for any old user, we'll need handle
    if {(($handle == "") || ($handle == "*")) && ($condition != "")} {
      bMotion_putloglev 4 * "  --reject: no handle"
      continue
    }

    #else, if we're accepting anyone and they don't have a handle, and
    #we don't want a bot, then use nick
    if {(($handle == "") || ($handle == "*")) && ($condition == "") && ($bot == 0)} {
      bMotion_putloglev 4 * "  ++accept: $user (no handle)"
      lappend acceptable $user
      continue
    }

    #if we're looking for a bot, drop this entry if it's not one
    if {$bot == 1} {
      if {![matchattr $handle b]} {
        bMotion_putloglev 4 * "  --reject: not a bot"
        continue
      }
      #check we can talk to this bot
      global bMotion_interbot_otherbots
      if {[lsearch [array names bMotion_interbot_otherbots] $handle] == -1} {
        bMotion_putloglev 4 * "  --reject: not a bmotion bot"
        continue
      }
      #else add them
      lappend acceptable $user
      bMotion_putloglev 4 * "  ++accept: bmotion bot"
      continue
    }

    #conversely if we're looking for a user...
    if {($bot == 0) && [matchattr $handle b]} {
      bMotion_putloglev 4 * "  --reject: not a user"
      continue
    }

    switch $condition {
      "" {
        bMotion_putloglev 4 * "  ++accept: any"
        lappend acceptable $handle
        continue
      }
      "male" {
        if {[getuser $handle XTRA gender] == "male"} {
          bMotion_putloglev 4 * "  ++accept: male"
          lappend acceptable $handle
          continue
        }
      }
      "female" {
        if {[getuser $handle XTRA gender] == "female"} {
          bMotion_putloglev 4 * "  ++accept: female"
          lappend acceptable $handle
          continue
        }
      }
      "like" {
        if {[bMotionLike $user [getchanhost $user]]} {
          bMotion_putloglev 4 * "  ++accept: like"
          lappend acceptable $handle
          continue
        }
      }
      "dislike" {
        if {![bMotionLike $user [getchanhost $user]]} {
          bMotion_putloglev 4 * "  ++accept: dislike"
          lappend acceptable $handle
          continue
        }
      }
      "friend" {
        if {[getFriendshipHandle $user] > 50} {
          bMotion_putloglev 4 * "  ++accept: friend"
          lappend acceptable $handle
          continue
        }
      }
      "enemy" {
        if {[getFriendshipHandle $user] < 50} {
          bMotion_putloglev 4 * "  ++accept: enemy"
          lappend acceptable $handle
          continue
        }
      }
    }
  }
  bMotion_putloglev 4 * "acceptable users: $acceptable"
  if {[llength $acceptable] > 0} {
    set user [pickRandom $acceptable]
    set index "lastruser$bot"
    set bMotionCache($index) $user
    return $user
  } else {
    if {$condition != ""} {
      return [bMotion_choose_random_user $channel $bot ""]
    } else {
      return ""
    }
  }
}

proc bMotionMakePossessive { text { altMode 0 }} {
	bMotion_putloglev 5 * "bMotionMakePossessive ($text, $altMode)"
  if {$text == ""} {
    return "someone's"
  }

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

proc bMotionMakeRepeat { text } {
	bMotion_putloglev 5 * "bMotionMakeRepeat ($text)"
  if [regexp {([0-9]+):([0-9]+):(.+)} $text matches min max repeat] {
		bMotion_putloglev 4 * "bMotionMakeRepeat: min = $min, max = $max, text = $repeat"
    set diff [expr $max - $min]
    if {$diff < 1} {
    	set diff 1
    }
    set count [rand $diff]
    set repstring [string repeat $repeat $count]
    append repstring [string repeat $repeat $min]
    return $repstring
  }
	bMotion_putloglev 4 * "bMotionMakeRepeat: no match (!), returning nothing"
  return ""
}

proc bMotion_strip_article { text } {
	bMotion_putloglev 5 * "bMotion_strip_article ($text)"
		regsub "(an?|the|some) " $text "" text
		return $text
}

proc bMotionMakeVerb { text } {
	bMotion_putloglev 5 * "bMotionMakeVerb ($text)"
  if [regexp -nocase "(s|x)$" $text matches letter] {
    return $text
  }

  if [regexp -nocase "^(.*)y$" $text matches root] {
    set verb $root
    append verb "ies"
    return $verb
  }

  append text "s"
  return $text
}
proc chr c {
    if {[string length $c] > 1 } { error "chr: arg should be a single char"}
		#   set c [ string range $c 0 0]
		    set v 0;
				    scan $c %c v; return $v
						}


proc bMotionMakePlural { text } {
  bMotion_putloglev 5 * "bMotionMakePlural ($text)"

  if [regexp -nocase "(us|is|x|ch)$" $text] {
    append text "es"
    return $text
  }

  if [regexp -nocase "s$" $text] {
    return $text
  }

  if [regexp -nocase "^(.*)f$" $text matches root] {
    set plural $root
    append plural "ves"
    return $plural
  }

  if [regexp -nocase "^(.*)y$" $text matches root] {
    set plural $root
    append plural "ies"
    return $plural
  }

  append text "s"
  return $text

}

bMotion_putloglev d * "bMotion: output module loaded"
