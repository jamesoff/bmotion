## bMotion plugin: pokemon stuff ;)
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

bMotion_plugin_add_complex "attack" "^%botnicks,?:? (use (your )?)?(.+) attack" 100 bMotion_plugin_complex_attack "en"
bMotion_plugin_add_complex "chooseyou" "^%botnicks:?,? i choose you(,? ?(.+))?" 100 bMotion_plugin_complex_chooseyou "en"
bMotion_plugin_add_simple "pokemon_return" "^${botnicks},?:? return" 100 [list "/returns to %%'s pokeball"] "en"

proc bMotion_plugin_complex_attack { nick host handle channel text } {
  global botnicks botnick mood
  if [regexp -nocase "^${botnicks}:? (use (your )?)?(.+)" $text ming ming1 ming2 ming2 what] {
    global bMotionInfo botnicks
    if [regexp -nocase {[[:<:]]attack[[:>:]]} [string tolower $what]] {
      global mood
      set attack [string range $what 0 [expr [string first "attack" [string tolower $what]] - 2]]
      bMotion_putloglev d * "bMotion: Requested attack: $attack"
      set onwhom [string range $what [expr [string first "attack" [string tolower $what]] + 6] end]
      set who ""
      if {[string length $onwhom] > 0} {
        if [regexp -nocase "(against|on|at) (.+)" $onwhom ming ming1 who] {
          set who [string tolower $who]
        }
      }
      set onwhom $who
      if [regexp -nocase "($botnicks|you|yourself)" $who] {
        set who "$nick instead"
      }

      if [regexp -nocase "thunder(bolt|shock)" $attack ming actualAttack] {
        checkPokemon "Pikachu" $channel
        if {$mood(electricity) < 0} {
          bMotionDoAction $channel $nick "pikaa...."
          bMotionDoAction $channel $nick "/collapses"
          putserv "NOTICE $nick :Sorry, I don't have enough power for a thunder$actualAttack at the moment :("
          bMotionDoAction $channel $nick "... pikachu :("
          return 1
        }
        incr mood(electricity) -3
        bMotionDoAction $channel $nick "pikaaa.... CHUUUUU"
        if {$who == ""} { bMotionDoAction $channel $nick "/fires [getHisHer] <notopic>thunder$actualAttack</notopic>!" } else {
          bMotionDoAction $channel $who "/fires [getHisHer] <notopic>thunder$actualAttack</notopic> at %%"
        }
        return 1
      }

      if [string match "*agility*" $attack] {
        checkPokemon "Pikachu" $channel
        bMotionDoAction $channel $nick "pikachu!"
        if {$who == ""} { bMotionDoAction $channel $nick "/runs around the channel in a random fashion!" } else {
          bMotionDoAction $channel $who "/runs rings around %%"
        }
        return 1
      }

      if [string match "*lightning*" $attack] {
        checkPokemon "Pikachu" $channel
        if {$mood(electricity) < 0} {
          bMotionDoAction $channel $nick "pikaa...."
          bMotionDoAction $channel $nick "/collapses"
          putserv "NOTICE $nick :Sorry, I don't have enough power for a lightning attack at the moment :("
          bMotionDoAction $channel $nick "... pikachu :("
          return 1
        }
        incr mood(electricity) -2
        bMotionDoAction $channel $nick "pikaaa.... CHUUUUU"
        if {$who == ""} { bMotionDoAction $channel $nick "/fires [getHisHer] lightning attack!" } else {
          bMotionDoAction $channel $who "/fires [getHisHer] lightning attack at %%"
        }
        return 1
      }

      if [string match "*monkey*" $attack] {
        checkPokemon "Damoachu" $channel
        bMotionDoAction $channel $nick "Damoa...chu!"
        if {$who == ""} { 
          bMotionDoAction $channel $nick "*monkey* *monkey* *monkey* *squirtle*"
        } else {
          bMotionDoAction $channel $who  "*monkey* *monkey* *monkey* *squitle at %%*"
        }
        return 1
      }

      if [string match "*gigaskrill*" $attack] {
        checkPokemon "Skrillachu" $channel
        bMotionDoAction $channel $nick "sssskrrillll...ACHU!"
        if {$who == ""} {
          bMotionDoAction $channel $nick "/activates [getHisHer] gigaskill attack"
        } else {
          bMotionDoAction $channel $who "/activates [getHisHer] gigaskill attack against %%"
        }
        return 1
      }


      # Everything else
      if [regexp -nocase "(against|on|at) (.+)" $text ming ming1 who] {
        bMotionDoAction $channel $who "$bMotionInfo(pokemon)!"
        bMotionDoAction $channel $who "/uses [getHisHer] $attack attack against $who"
        return 1
      } else {
        bMotionDoAction $channel "" "$bMotionInfo(pokemon)! *$attack attack*"
      }
      return 1
    }
  }
}

proc bMotion_plugin_complex_chooseyou { nick host handle channel text } {
  if [regexp -nocase "^${botnicks}:?,? i choose you(,? ?(.+))?" $text ming ming1 who] {
    if {$who == ""} {
      bMotionDoAction $channel $nick "er, thanks :P"
      return 1
    }
    checkPokemon $who $channel
  }
}