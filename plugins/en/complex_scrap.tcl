# 
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) Gregory Christiaan Sweetman 2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#
# Causes the bot to give a basic description of a "scrapheap-challenge" type vehicle / construction
# Syntax : !scrap [ silly ]
#
# Output : [Quality] [Adjective [Adjective2]] [Power] Construction
# E.g. "Bent" "Steam Driven" "Barge"
#
# Silly switch will introduce strange descriptions, such as a "greasy lunar powered blamanche"
#


proc bMotion_plugin_complex_scrap { nick host handle channel text } {
  if [regexp -nocase "^!scrap( silly| xxx)?$" $text blah silly] {
    # output from output_english.tcl automatically corrects bad grammar of "a " followed by a vowel.
    set output "A ";
    # quality
    if [rand 2] {
      if {$silly != ""} {
        append output "%VAR{scrap_silly_qualities} "
      } else {
        append output "%VAR{scrap_qualities} "
      }
    }

    # adjectives
    if [rand 2] {
      if {$silly != ""} {
        append output "%VAR{scrap_silly_adjectives} "
        if [rand 2] {
          append output "%VAR{scrap_silly_adjectives2} "
        }
      } else {
        append output "%VAR{scrap_adjectives} "
        if [rand 2] {
          append output "%VAR{scrap_adjectives2} "
        }
      }
    }

    # power
    if [rand 2] {
      if {$silly != ""} {
        append output "%VAR{scrap_silly_power_adjectives} "
      } else {
        append output "%VAR{scrap_power_adjectives} "
      }
    }

    # construction
    if {$silly != ""} {
      append output "%VAR{scrap_silly_construction}"
    } else {
      append output "%VAR{scrap_construction}"
    }

    bMotionDoAction $channel "" $output

    #undo the flood protection
    bMotion_flood_undo $nick
  }
}

bMotion_plugin_add_complex "scrap" "^!scrap" 100 bMotion_plugin_complex_scrap "en"

set scrap_qualities {
  "broken"
  "cheap"
  "irrepairable"
  "novice"
  "shoddy"
  "poor"
  "bad"
  "very bad"
  "terrible"

  "average"
  "amateur"
  "passable"
  "ok"
  "good"
  "normal"
  "fair"

  "master crafted"
  "perfect"
  "expensive"
  "premium"
  "professional"
  "quality"
  "superior"
  "first rate"
  "super"
  "legendary"
  "excellent"
}

set scrap_adjectives {
  "broken down"
  "greasy"
  "bent"
  "blunt"
  "rusty"
  "battered"
  "bashed"
  "riveted"
  "working"
  "damaged"
  "forsaken"
  "chipped"
  "loose"
  "second hand"
  "splintered"
  "worn"
  "balanced"
  "engineered"
  "sharp"
  "polished"
  "composite"
  "layered"
  "over-tuned"
  "mamoth"
  "tiny"
  "small"
  "medium sized"
  "large"
  "huge"
  "massive"
  "miniscule"
  "stiff"
  "flexible"

  "dirt driving"
  "muck mulching"
  "pete ploughing"
  "corn collecting"
  "metal mashing"
  "welly wanging"
  "creek crossing"
  "ditch digging"
  "rough riding"
}

set scrap_power_adjectives {
  "super powered"
  "steam powered"
  "wind powered"
  "solar powered"
  "diesel powered"
  "electric"
  "hydraulic"
  "pneumatic"
  "motorised"
  "manual"
  "mechanical"
  "kinetic"
  "clockwork"
  "electronic"
  "biological"
  "unpowered"
}

set scrap_construction {
  "barge"
  "submarine"
  "torpedo"
  "tractor"
  "combine harvestor"
  "bolt cutter"
  "generator"
  "digger"
  "monowheel"
  "hovercraft"
  "car crusher"
  "train"
  "railroad racer"
  "tug"
  "automatic rifle"
  "air cannon"
  "drag racer"
  "liquid transporter"
  "cable car"
  "monorail"
  "motorbike"
  "wood cutter"
  "raft"
  "jet-ski"
  "crop duster"
  "aeroplane"
  "glider"
  "helicopter"
  "monster truck"
  "grenade launcher"
  "golf-ball-driver"
  "go kart"
  "scooter"
  "4X4"
  "landing craft"
  "dodgem"
  "pistol"
  "signal flare"
  "wagon"
  "bus"
  "APC"
}

set scrap_silly_qualities_t {
  "weird"
  "strange"
  "bizzare"
  "alien"
}

set scrap_silly_adjectives_t {
  "spotty"
  "furry"
  "inflatable"

  "mighty morphing"
  "wacky racing"
  "rib tickling"
}

set scrap_silly_power_adjectives_t {
  "lunar powered"
  "psychicly charged"
  "hamster powered"
  "soul powered"
  "%ruser powered"
  "%VAR{sillyThings} driven"
}

set scrap_silly_construction_t {
  "blamanche"
  "fork"
  "knife"
  "plate"
  "spoon"
  "party popper"
  "zord"
  "mega zord"
  "turbo mega power zord"
  "transformer"
  "beany baby"
  "unicycle"
  "baby"
  "welly wanger"
}

#create the big lists :)
set scrap_silly_qualities [concat $scrap_qualities $scrap_silly_qualities_t]
set scrap_silly_power_adjectives [concat $scrap_power_adjectives $scrap_silly_power_adjectives_t]
set scrap_silly_adjectives [concat $scrap_adjectives $scrap_silly_adjectives_t]
set scrap_silly_construction [concat $scrap_construction $scrap_silly_construction_t]

#duplicate for second adjectives
set scrap_silly_adjectives2 $scrap_silly_adjectives
set scrap_adjectives2 $scrap_adjectives