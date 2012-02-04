#
# vim: set foldmarker=<<<,>>>
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# NOTE:
# This plugin is designed to interact with the TriviaEngine TCL script
# As of 20070624, the TriviaEngine is not OSS, so don't bother asking :P
# If you want to come and play, find us in #triviacow on EFNet.

# This file registers no plugins as it's all triggered via botnet commands
set bMotion_noplugins 1

proc bMotion_plugin_complex_trivia_botnet { bot command params } {
	if {$command != "trivia"} {
		return
	}

	if [regexp "^(.+) :(.*)" $params matches cmd arg] {
		switch $cmd {
			"start" {
				bMotion_putloglev d * "trivia: received start command from $bot for channel $arg"
				bMotion_plugin_complex_trivia_init $arg
				return
			}

			"stop" {
				bMotion_putloglev d * "trivia: received stop command from $bot"
				bMotion_plugin_complex_trivia_stop
				return
			}

			"hint" {
				bMotion_putloglev d * "trivia: recieved hint from $bot: $arg"
				bMotion_plugin_complex_trivia_hint $arg
				return
			}

			"winner" {
				bMotion_putloglev d * "trivia: received winner from $bot: $arg"
				bMotion_plugin_complex_trivia_winner $arg
				return
			}
			default {
				bMotion_putloglev d * "trivia: received unknown command $cmd with params $arg from $bot"
			}
		}
	}
}

bind bot - "trivia" bMotion_plugin_complex_trivia_botnet

proc bMotion_plugin_complex_trivia_delay { } {
	set delay [bMotion_plugins_settings_get "trivia" "delay" "" ""]

	if {$delay != ""} {
		set quarter [expr $delay / 4]
		set lmt [expr $quarter * 1]
		return [expr [rand $quarter] + $lmt]
	}
}

# be told about the start of a round remotely
proc bMotion_plugin_complex_trivia_init { info } {
	if [regexp {(#[^ ]+) ([0-9]+) (.+)} $info matches channel roundlength bot] {
		bMotion_plugins_settings_set "trivia" "channel" "" "" $channel
		bMotion_plugins_settings_set "trivia" "type" "" "" "normal"
		bMotion_plugins_settings_set "trivia" "played" "" "" 0
		bMotion_plugins_settings_set "trivia" "hint" "" "" ""
		bMotion_plugins_settings_set "trivia" "tries" "" "" 0
		bMotion_plugins_settings_set "trivia" "delay" "" "" $roundlength
		bMotion_plugins_settings_set "trivia" "bot" "" "" $bot
		bMotion_putloglev 1 * "trivia: informed of round start in $channel, delay = $roundlength"

		#start a short timer (add extra delay for the text to escape from TriviaCow)
		set delay [expr [bMotion_plugin_complex_trivia_delay] + 4]
		bMotion_putloglev 1 * "trivia: try guessing in $delay seconds"
		bMotion_plugins_settings_set "trivia" "timer" "" "" [utimer $delay bMotion_plugin_complex_trivia_auto]
	}
}

# be told about a new hint
proc bMotion_plugin_complex_trivia_hint { hint } {
	bMotion_plugins_settings_set "trivia" "hint" "" "" $hint
	bMotion_putloglev 1 * "trivia: informed of hint: $hint"
}

# be told the round is over and who won
proc bMotion_plugin_complex_trivia_winner { info } {
	bMotion_plugins_settings_set "trivia" "type" "" "" ""
	bMotion_plugins_settings_set "trivia" "hint" "" "" ""
	set channel [bMotion_plugins_settings_get "trivia" "channel" "" ""]

	if [regexp {^([^ ]+) (.+)} $info matches winner answer] {
		set answer [string tolower $answer]
		bMotion_putloglev d * "trivia: answer was $answer"

		set words [split $answer " "]
		foreach word $words {
			if [regexp {([a-zA-Z1]+)} $word matches newword] {
				set word $newword
			}
			set word [string tolower $word]
			set firstletter [string toupper [string range $word 0 0]]
			set full_array_name_for_upvar "afro_$firstletter"
			bMotion_putloglev d * "trivia: adding $word to $full_array_name_for_upvar"
			bMotion_abstract_add $full_array_name_for_upvar $word
		}

		#react to who won
		bMotion_plugins_settings_set "trivia" "channel" "" "" ""

		if {$winner == "*"} {
			#noone won
			bMotion_putloglev d * "trivia: noone won this round"
      if {![rand 20]} {
        bMotionDoAction $channel [bMotion_plugins_settings_get "trivia" "bot" "" ""] "%VAR{bahs}"
      }
		} else {
			# someone got it right
			if [isbotnick $winner] {
				#it was me
				bMotion_putloglev d * "trivia: i won!"
				bMotionDoAction $channel "" "%VAR{trivia_wins}"
			} else {
				#it was someone else
				bMotion_putloglev d * "trivia: somone else won :("
        if {(![rand 10]) && ([bMotion_plugins_settings_get "trivia" "type" "" ""] != "year")} {
          bMotionDoAction $channel $winner "%VAR{trivia_loses}"
        }
			}
		}
	}
}

# be told to stop (i.e. someone stopped the game manually
proc bMotion_plugin_complex_trivia_stop { } {
	bMotion_plugins_settings_set "trivia" "type" "" "" ""
	bMotion_plugins_settings_set "trivia" "channel" "" "" ""
	bMotion_plugins_settings_set "trivia" "hint" "" "" ""
}

proc bMotion_plugin_complex_trivia_guess { nick host handle channel text } {
  set bMotionOriginalInput $text

  set tries [bMotion_plugins_settings_get "trivia" "tries" "" ""]
	if {$tries == ""} {
		set tries 0
	}
  incr tries
  if {$tries > 4} {
    #give up auto-guessing until next clue
    bMotion_putloglev 1 * "trivia: giving up guessing trivia after 4 tries..."
    return 0
  }
  bMotion_plugins_settings_set "trivia" "tries" "" "" $tries
	bMotion_putloglev 1 * "trivia: making attempt $tries"

	set hinttext [bMotion_plugins_settings_get "trivia" "hint" "" ""]
	if {$hinttext == ""} {
		bMotion_putloglev d * "trivia: no hint, aborting guess"
		return
	}

	bMotion_putloglev 1 * "trivia: current hint is $hinttext"

  set hintlist [split $hinttext " "]
  set answer ""
  set elementcount [llength $hintlist]
  set elements 0

  foreach hint $hintlist {
    set hint [string trim $hint]
    if {$hint != ""} {
      bMotion_putloglev 1 * "trivia: processing hint $hint"
      set firstletter [string range $hint 0 0]
      if {$firstletter == "."} {
				bMotion_putloglev 1 * "trivia: unknown first char, making it up"
        if {[bMotion_plugins_settings_get "trivia" "type" "" ""] == "year"} {
          set firstletter "1"
        } else {
          set firstletter [pickRandom [split "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {}]]
					bMotion_putloglev 1 * "trivia: invented $firstletter as first letter"
        }
      }
      if [regexp {[A-Z1]} $firstletter] {
        bMotion_putloglev 1 * "trivia: looking for a $firstletter word..."
        set upvar_name "afro_$firstletter"
        set wordlist [bMotion_abstract_all $upvar_name]
        #find a matching word
        set candidates [list]
        foreach word $wordlist {
          if [regexp -nocase "^${hint}$" $word] {
            lappend candidates $word
          }
        }
        if {[llength $candidates] > 0} {
          append answer "[pickRandom $candidates] "
          incr elements
        }
      }
    } else {
      #decrement the number of elements needed
      incr elementcount -1
    }
  }
	
	# slow down guessing a bit
	if [rand 2] {
		return 2
	}

  if {($elements == $elementcount)} {
    set answer [string trim $answer]
    if {$answer != [bMotion_plugins_settings_get "trivia" "last" "" ""]} {
      #final parameter of 1 is to skip output plugins (we don't want our answer processed)
      #putlog "about to call bMotionDoAction"
      #bMotionDoAction $channel $nick $answer lalala 1
      bMotionDoAction $channel $nick $answer nothing 1
      bMotion_putloglev d * "trivia: answered trivia with $answer"
      bMotion_plugins_settings_set "trivia" "last" "" "" $answer
      bMotion_plugins_settings_set "trivia" "played" "" "" 1

      #since we have an answer and it's different, let's have another guess shortly
      bMotion_plugins_settings_set "trivia" "hint" "" "" $bMotionOriginalInput
      bMotion_plugins_settings_set "trivia" "channel" "" "" $channel
      set delay [bMotion_plugin_complex_trivia_delay]
      bMotion_putloglev d * "trivia: will try trivia again in $delay seconds"
      bMotion_plugins_settings_set "trivia" "timer" "" "" [utimer $delay bMotion_plugin_complex_trivia_auto]
    } else {
      bMotion_putloglev d * "trivia: skipped answering with $answer, same as last time"
    }
  } else {
		bMotion_putloglev d * "trivia: unable to find enough matching words, not guessing"
		if [regexp {^[. ]+$} [bMotion_plugins_settings_get "trivia" "hint" "" ""]] {
			set delay [bMotion_plugin_complex_trivia_delay]
			bMotion_putloglev d * "trivia: will try trivia again in $delay seconds"
			bMotion_plugins_settings_set "trivia" "timer" "" "" [utimer $delay bMotion_plugin_complex_trivia_auto]
		}
		if {![rand 100]} {
			bMotionDoAction $channel "" "permafrost"
		}
	}
	return 2
}

proc bMotion_plugin_complex_trivia_auto { } {
	if {[bMotion_plugins_settings_get "trivia" "type" "" ""] != ""} {
		set channel [bMotion_plugins_settings_get "trivia" "channel" "" ""]
		if {$channel != ""} {
			bMotion_putloglev d * "auto-guessing for trivia again..."
			bMotion_plugin_complex_trivia_guess "" "" "" $channel [bMotion_plugins_settings_get "trivia" "hint" "" ""]
		}
	}
}

#set up the abstracts
foreach letter [split "ABCDEFGHIJKLMNOPQRSTUVWXYZ1" {} ] {
  bMotion_abstract_register "afro_$letter"
}

bMotion_abstract_register "bahs" [list "dang" "blast" "i was close %VAR{unsmiles}" "%colen" "curse you %%" "blah" "bleh" "damnit" "S%REPEAT{1:4:O} CLOSE" "no fair, %ruser told me the wrong answer %VAR{unsmiles}"]

bMotion_abstract_register "trivia_wins" [list "%VAR{harhars}" "own3d" "PWND!" "yes!" "w%REPEAT{3:6:o}!" "go %me, go %me!" "whe%REPEAT{3:7:e}" "muhar" "winnar!" "in your face, %ruser!"]

bMotion_abstract_register "trivia_loses" [list "hey stop copying me %VAR{unsmiles}" "i was going to say that next" "hay you're cheating %VAR{unsmiles}" "you're in league with the bot, i know it" "that's not the right answer; the right answer is obviously '%VAR{sillyThings}'" "feh" "*cough*google*cough*" "toss" "%VAR{unsmiles}" "I was distracted by %VAR{sillyThings}" "i wish i knew as much as you. really." "/dumb" "/stupid" "i knew that"]
