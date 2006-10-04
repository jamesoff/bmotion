# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_plugin_complex_abbr { nick host handle channel text } {
  global abbr_nouns abbr_verbs abbr_adj
  global abbr_adult_nouns abbr_adult_verbs abbr_adult_adj

  if [regexp -nocase "^!abbr( adult| xxx)?$" $text blah adult] {
    if {$adult == ""} {
      set noun1 [pickRandom $abbr_adj]
      set noun2 [pickRandom $abbr_nouns]
      set verb [pickRandom $abbr_verbs]
    } else {
      set noun1 [pickRandom $abbr_adult_adj]
      set noun2 [pickRandom $abbr_adult_nouns]
      set verb [pickRandom $abbr_adult_verbs]
    }

    #get the acronym
    set acronym ""
    append acronym [string range $noun1 0 0]
    append acronym [string range $verb 0 0]
    append acronym [string range $noun2 0 0]

    set acronym [string toupper $acronym]

    bMotionDoAction $channel "" "$acronym: ${noun1}-${verb}-$noun2"
    return 1
  }
}

bMotion_plugin_add_complex "abbr" "^!abbr" 100 bMotion_plugin_complex_abbr "en"

set abbr_nouns {
  "mullet"
  "cheese"
  "individual"
  "cellular"
  "cup"
  "monitor"
  "desk"
  "teddy" "shirt" "phaser" "klingon" "shoe" "black" "crunch" "celeb" "bounce" "grape" "spit" "hole" "gravel" "dung" "heap" "sheep" "crash" "screen" "crisps" "sword" "maple" "fish" "hip-hop" "wesley" "toilet"
}

set abbr_adj {
  "hot" "cold" "purple" "clean" "freezing" "thooper" "white" "starchy" "bavarian" "woolly" "blippy" "decent" "smart" "coloured" "flavoured" "norwegian" "swede" "brit" "dutchman" "american" "canadian" "german"
}

set abbr_verbs {
  "wielding"
  "powered"
  "enabled"
  "spinning" "cycling" "phasing" "sounding" "clapping" "shoving" "plowing" "screwed" "thinking" "holding" "shooting" "warping" "beaming" "tasting" "smelling"
}


set abbr_adult_nouns_t {
  "sex"
  "vibrator"
  "rubber"
  "lace"
  "package" "knickers" "dildo" "vibrator" "sex" "nipple" "bum" "stockings" "rabbit"
}

set abbr_adult_adj_t {
  "thexy" "horny"
  "hot" "moist" "wet" "lubricated"
}

set abbr_adult_verbs_t {
  "licking"
  "moaning"
  "licking" "pumping" "grinding" "rubbing" "ooh-ahhing" "screwing" "oomphing"
}

#create the big lists :)
set abbr_adult_nouns [concat $abbr_nouns $abbr_adult_nouns_t]
set abbr_adult_verbs [concat $abbr_verbs $abbr_adult_verbs_t]
set abbr_adult_adj [concat $abbr_adj $abbr_adult_adj_t]
