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

# [@   fluffy] Show 'em how it's done Bel! The answer was DARLING.
bMotion_plugin_add_complex "trivia3" ".+ The (correct )?answer was.+" 100 bMotion_plugin_complex_trivia_3 "en"


#
# Detect the start of the game
proc bMotion_plugin_complex_trivia_1 { nick host handle channel text } {
  bMotion_plugins_settings_set "trivia" "nick" "" "" $nick
  bMotion_plugins_settings_set "trivia" "channel" "" "" $channel
  bMotion_putloglev 2 * "Detected start of trivia round"
  bMotion_flood_clear $nick
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

  global bMotionOriginalInput
  # have to do this because bmotion contracts double spaces for us
  set text $bMotionOriginalInput

  #definitely playing
  bMotion_putloglev 1 * "detected trivia hint: $text"


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
        set firstletter [pickRandom [split "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {}]]
      }
      if [regexp {[A-Z1]} $firstletter] {
        bMotion_putloglev 1 * "looking for a $firstletter word..."
        set upvar_name "afro_$firstletter"
        #upvar #0 $upvar_name wordlist
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
      bMotionDoAction $channel $nick $answer
      putloglev d * "answered trivia with $answer"
      bMotion_plugins_settings_set "trivia" "last" "" "" $answer
    } else {
      putloglev d * "skipped answering with $answer, same as last time"
    }
  }
}

proc bMotion_plugin_complex_trivia_3 { nick host handle channel text } {
  bMotion_plugins_settings_set "trivia" "nick" "" "" ""
  bMotion_plugins_settings_set "trivia" "channel" "" "" ""
  #let's remember this answer
  #putlog $text
  if [regexp -nocase {answer was ([^\.]+)\.} $text matches answer] {
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

#set up the abstracts
foreach letter [split "ABCDEFGHIJKLMNOPQRSTUVWXYZ1" {} ] {
  bMotion_abstract_register "afro_$letter"
}