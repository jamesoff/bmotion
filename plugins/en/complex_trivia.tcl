## bMotion plugin: blblbl
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#[@   fluffy] ===== Question 1807/12605  =====
bMotion_plugin_add_complex "trivia1" {^===== Question .+ =====$} 100 bMotion_plugin_complex_trivia_1 "en"

#[@   fluffy] Hint: _ _ _ _ _ _ _ _ _
bMotion_plugin_add_complex "trivia2" {^Hint:} 85 bMotion_plugin_complex_trivia_2 "en"

#[      zeal] Name The Year: Calvin Coolidge, 30th US President, died.
bMotion_plugin_add_complex "trivia4" "^Name the year:" 100 bMotion_plugin_complex_trivia_4 "en"

# [@   fluffy] Show 'em how it's done Bel! The answer was DARLING.
bMotion_plugin_add_complex "trivia3" ".+ The (correct )?answer was.+" 100 bMotion_plugin_complex_trivia_3 "en"

#
#bMotion_plugin_add_complex "trivia4" "^Name the year:" 100 bMotion_plugin_complex_trivia_4 "en"

#
# Detect the start of the game
proc bMotion_plugin_complex_trivia_1 { nick host handle channel text } {
  bMotion_plugins_settings_set "trivia" "nick" "" "" $nick
  bMotion_plugins_settings_set "trivia" "channel" "" "" $channel
  bMotion_plugins_settings_set "trivia" "type" "" "" ""
  bMotion_putloglev 2 * "Detected start of trivia round"
  bMotion_flood_clear $nick
}

proc bMotion_plugin_complex_trivia_4 { nick host handle channel text } {
  if {$channel != [bMotion_plugins_settings_get "trivia" "channel" "" ""]} {
    return 0
  }
  if {$nick != [bMotion_plugins_settings_get "trivia" "nick" "" ""]} {
    return 0
  }
  bMotion_plugins_settings_set "trivia" "type" "" "" "year"
}

#
# Here's a hint... let's try to answer
proc bMotion_plugin_complex_trivia_2 { nick host handle channel text } {
  if {$channel != [bMotion_plugins_settings_get "trivia" "channel" "" ""]} {
    return 0
  }
  if {$nick != [bMotion_plugins_settings_get "trivia" "nick" "" ""]} {
    return 0
  }

  bMotion_flood_clear $nick

  bMotion_plugins_settings_set "trivia" "tries" "" "" 0

  catch {
    killutimer [bMotion_plugins_settings_get "trivia" "timer" "" ""]
    bMotion_putloglev d * "killed trivia retry timer"
  }

  global bMotionOriginalInput
  # have to do this because bmotion contracts double spaces for us
  set text $bMotionOriginalInput
  bMotion_plugins_settings_set "trivia" "hint" "" "" $text

  #definitely playing
  bMotion_putloglev 1 * "detected trivia hint: $text"

  #don't guess first time round
  #bMotion_plugin_complex_trivia_guess $nick $host $handle $channel $text

  #instead start a short timer
  set delay [expr [rand 15] + 2]
  bMotion_putloglev d * "try trivia first again in $delay seconds"
  bMotion_plugins_settings_set "trivia" "timer" "" "" [utimer $delay bMotion_plugin_complex_trivia_auto]

}

proc bMotion_plugin_complex_trivia_3 { nick host handle channel text } {
  global botnicks

  bMotion_plugins_settings_set "trivia" "nick" "" "" ""
  bMotion_plugins_settings_set "trivia" "channel" "" "" ""
  bMotion_plugins_settings_set "trivia" "type" "" "" ""
  catch {
    killutimer [bMotion_plugins_settings_get "trivia" "timer" "" ""]
    bMotion_putloglev d * "killed trivia retry timer"
  }

  #let's remember this answer
  #putlog $text
  if [regexp -nocase {(correct )?answer was ([^\.]+)\.} $text matches correct answer] {
    if {$correct != ""} {
      if {![rand 10]} {
        bMotionDoAction $channel $nick "%VAR{bahs}"
      }
    }

    #if my nick is in the line, i must have got it right
    if [regexp -nocase "${botnicks}!" $text] {
      bMotionDoAction $channel $nick "%VAR{trivia_wins}"
    } else {
      #my nick isn't, so is "correct" (someone else got it)
      if {![regexp "correct answer" $text]} {
        if {![rand 10]} {
          bMotionDoAction $channel $nick "%VAR{trivia_loses}"
        }
      }
    }

    set words [split $answer " "]
    foreach word $words {
      if [regexp {([a-zA-Z1]+)} $word matches newword] {
        set word $newword
      }
      set word [string tolower $word]
      set firstletter [string toupper [string range $word 0 0]]
      set full_array_name_for_upvar "afro_$firstletter"
      #bMotion_putloglev d * "looking for $full_array_name_for_upvar"
      #upvar #0 $full_array_name_for_upvar teh_variable
      #if {[lsearch $teh_variable $word] == -1} {
        #lappend teh_variable $word
        #bMotion_putloglev d * "trivia: learning word $word"
      #}
      bMotion_abstract_add $full_array_name_for_upvar $word
    }
  }
  bMotion_flood_clear $nick
}

proc bMotion_plugin_complex_trivia_guess { nick host handle channel text } {
  set bMotionOriginalInput $text

  set tries [bMotion_plugins_settings_get "trivia" "tries" "" ""]
  incr tries
  if {$tries > 4} {
    #give up auto-guessing until next clue
    bMotion_putloglev d * "giving up guessing trivia after 4 tries..."
    return 0
  }
  bMotion_plugins_settings_set "trivia" "tries" "" "" $tries

  #remove {}s
  regsub -all {[\{\}]} $text " " text

  #extract the hint
  regexp {^Hint: ([_ A-Z])+} $text matches hinttext
  catch {
    if {$hinttext == ""} {
      return 1
    }
  }
  set hinttext [string range $text 6 end]
  set text [string trim $text]

  #split if needed
  regsub -all { ([_A-Z])} $hinttext "\\1" hinttext

  #turn _s to .s to make a regexp
  regsub -all "_" $hinttext "." hinttext

  bMotion_putloglev 2 * "contracted hint is $hinttext"

  set hintlist [split $hinttext " "]
  set answer ""
  set elementcount [llength $hintlist]
  set elements 0

  foreach hint $hintlist {
    set hint [string trim $hint]
    if {$hint != ""} {
      bMotion_putloglev 2 * "processing hint $hint"
      set firstletter [string range $hint 0 0]
      if {$firstletter == "."} {
        if {[bMotion_plugins_settings_get "trivia" "type" "" ""] == "year"} {
          set firstletter "1"
        } else {
          set firstletter [pickRandom [split "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {}]]
        }
      }
      if [regexp {[A-Z1]} $firstletter] {
        bMotion_putloglev 1 * "looking for a $firstletter word..."
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
  #putlog "elements: $elements, elementcount: $elementcount"
  if {($elements == $elementcount)} {
    set answer [string trim $answer]
    if {$answer != [bMotion_plugins_settings_get "trivia" "last" "" ""]} {
      #final parameter of 1 is to skip output plugins (we don't want our answer processed)
      #putlog "about to call bMotionDoAction"
      #bMotionDoAction $channel $nick $answer lalala 1
      bMotionDoAction $channel $nick $answer nothing 1
      putloglev d * "answered trivia with $answer"
      bMotion_plugins_settings_set "trivia" "last" "" "" $answer

      #since we have an answer and it's different, let's have another guess shortly
      bMotion_plugins_settings_set "trivia" "hint" "" "" $bMotionOriginalInput
      bMotion_plugins_settings_set "trivia" "channel" "" "" $channel
      set delay [expr [rand 15] + 10]
      bMotion_putloglev d * "will try trivia again in $delay seconds"
      bMotion_plugins_settings_set "trivia" "timer" "" "" [utimer $delay bMotion_plugin_complex_trivia_auto]
    } else {
      putloglev d * "skipped answering with $answer, same as last time"
    }
  }
}

proc bMotion_plugin_complex_trivia_auto { } {
  set channel [bMotion_plugins_settings_get "trivia" "channel" "" ""]
  if {$channel != ""} {
    bMotion_putloglev d * "auto-guessing for trivia again..."
    bMotion_plugin_complex_trivia_guess "" "" "" $channel [bMotion_plugins_settings_get "trivia" "hint" "" ""]
  }
}

#set up the abstracts
foreach letter [split "ABCDEFGHIJKLMNOPQRSTUVWXYZ1" {} ] {
  bMotion_abstract_register "afro_$letter"
}

bMotion_abstract_register "bahs"
bMotion_abstract_batchadd "bahs" [list "dang" "blast" "i was close %VAR{unsmiles}" "%colen" "curse you %%" "blah" "bleh" "damnit" "S%REPEAT{1:4:O} CLOSE" "no fair, %ruser told me the wrong answer %VAR{unsmiles}"]

bMotion_abstract_register "trivia_wins"
bMotion_abstract_batchadd "trivia_wins" [list "%VAR{harhars}" "own3d" "PWND!" "yes!" "w%REPEAT{3:6:o}!" "go %me, go %me!" "whe%REPEAT{3:7:e}" "muhar" "winnar!" "in your face, %ruser!"]

bMotion_abstract_register "trivia_loses"
bMotion_abstract_batchadd "trivia_loses" [list "hey stop copying me %VAR{unsmiles}" "i was going to say that next" "hay you're cheating %VAR{unsmiles}" "you're in league with the bot, i know it" "that's not the right answer; the right answer is obviously '%VAR{sillyThings}'" "feh" "*cough*google*cough*" "toss" "%VAR{unsmiles}" "I was distracted by %VAR{sillyThings}" "i wish i knew as much as you. really." "/dumb" "/stupid" "i knew that"]