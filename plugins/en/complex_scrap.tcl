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
# Syntax : !scrap [ silly ] [ adult ]
#
# Output : [Quality] [Adjective [Adjective2]] [Power] Construction
# E.g. "Bent" "Steam Driven" "Barge"
#
# Silly switch will introduce strange descriptions, such as a "greasy lunar powered blamanche"
# Adult switch will introduce norty descriptions / devices.
#


proc bMotion_plugin_complex_scrap { nick host handle channel text } {

  if [regexp -nocase "^!scrap( silly| adult| xxx)?( silly| adult| xxx)?$" $text blah silly1 silly2] {

    # output from output_english.tcl automatically corrects bad grammar of "a " followed by a vowel.
    set output "A "

    set outputtype 0
    if {($silly1 == " silly") || ($silly2 == " silly")} {
      set outputtype [expr $outputtype + 1]
    }
    if {($silly1 == " adult") || ($silly2 == " adult") || ($silly1 == " xxx") || ($silly2 == " xxx")} {
      set outputtype [expr $outputtype + 2]
    }

# outputtype = 0 <-- regular output    
# outputtype = 1 <-- silly output    
# outputtype = 2 <-- adult output    
# outputtype = 3 <-- silly adult output    

    # quality
    if [rand 2] {
      switch -exact $outputtype {
        0 {
          append output "%VAR{scrap_qualities} "
        }
        1 {
          append output "%VAR{scrap_silly_qualities} "
        }
        2 {
          append output "%VAR{scrap_adult_qualities} "
        }
        3 {
          append output "%VAR{scrap_silly_adult_qualities} "
        }
      }
    }

    # adjectives
    if [rand 2] {
      switch -exact $outputtype {
        0 {
          append output "%VAR{scrap_adjectives} "
          if [rand 2] {
            append output "%VAR{scrap_adjectives2} "
          }
        }
        1 {
          append output "%VAR{scrap_silly_adjectives} "
          if [rand 2] {
            append output "%VAR{scrap_silly_adjectives2} "
          }
        }
        2 {
          append output "%VAR{scrap_adult_adjectives} "
          if [rand 2] {
            append output "%VAR{scrap_adult_adjectives2} "
          }
        }
        3 {
          append output "%VAR{scrap_silly_adult_adjectives} "
          if [rand 2] {
            append output "%VAR{scrap_silly_adult_adjectives2} "
          }
        }
      }
    }

    # power
    if [rand 2] {
      switch -exact $outputtype {
        0 {
          append output "%VAR{scrap_power_adjectives} "
        }
        1 {
          append output "%VAR{scrap_silly_power_adjectives} "
        }
        2 {
          append output "%VAR{scrap_adult_power_adjectives} "
        }
        3 {
          append output "%VAR{scrap_silly_adult_power_adjectives} "
        }
      }
    }

    # construction
    switch -exact $outputtype {
      0 {
        append output "%VAR{scrap_construction} "
      }
      1 {
        append output "%VAR{scrap_silly_construction} "
      }
      2 {
        append output "%VAR{scrap_adult_construction} "
      }
      3 {
        append output "%VAR{scrap_silly_adult_construction} "
      }
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
  "dirty"
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
  "oscillating"
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
  "remote controlled"
  "fully automatic"
  "semi automatic"
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
  "spring loaded"
  "winched"
  "chain driven"
  "pressurised"
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
  "rifle"
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
  "satellite"
  "go kart"
  "scooter"
  "bunker"
  "pillbox"
  "4X4"
  "landing craft"
  "dodgem"
  "pistol"
  "signal flare"
  "wagon"
  "bus"
  "APC"
  "rocket"
  "keyboard"
  "projector"
  "fan"
  "sword"
  "shield"
  "sledge"
  "lorry"
  "truck"
  "catapult"
  "missile"
  "gyroscope"
}

set scrap_silly_qualities_t {
  "weird"
  "strange"
  "bizzare"
  "alien"
  "mysterious"
  "elven"
  "orcish"
  "goblinoid"
  "magical"
}

set scrap_silly_adjectives_t {
  "spotty"
  "funny"
  "furry"
  "wobbly"
  "bouncy"
  "cuddly"
  "cute"
  "sweet"
  "ugly"
  "multi-coloured"
  "anti -"
  "inflatable"
  "virtual"

  "mighty morphing"
  "wacky racing"
  "rib tickling"
  "thigh slapping"
  "artificially intelligent"
  "manic mining"
}

set scrap_silly_power_adjectives_t {
  "lunar powered"
  "psychicly charged"
  "hamster powered"
  "soul powered"
  "%ruser powered"
  "%VAR{sillyThings} driven"
  "pure evil"
  "plasma powered"
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
  "beanie baby"
  "unicycle"
  "baby"
  "welly wanger"
  "football"
  "website"
  "server"
  "daemon"
  "imp"
  "angel"
  "ATAT"
  "star destroyer"
  "starship"
  "space station"
  "probe"
  "%ruser"
  "megaphone"
  "postbox"
  "starbase"
  "rabbit"
  "cartoon character"
  "prom dress"
  "hula skirt"
  "dunce's cap"
  "crown"
  "coktail machine"
  "beer keg"
  "action hero"
  "taunt"
  "teleporter"
  "phaser"
  "disruptor"
  "beam of light"
  "quark"
  "neutrino"
  "tachyon"
  "postcard"
  "printing press"
  "cash printing machine"
}

set scrap_adult_qualities_t {
  "well formed"
  "well rounded"
  "slinky"
  "slender"
  "slim"  
  "voluptuous"
  "bound"

  "minging"
  "doggish"
}

set scrap_adult_adjectives_t {
  "norty"
  "vary norty"
  "sexy"
  "horny"
  "firm"
  "supple"
  "sticky"
  "moist"
  "wet"
  "sweaty"
  "hot"
  "steamy"
  "licking"
  "tight"
  "curvy"
  "undulating"
  "girating"
  "shafting"
  "vibrating"
  "lubricating"
  "tasty"
  "fondling"
  "cuddling"
  "masturbating"
  "shagging"
  "fucking"
  "screwing"  
  "bulging"
  "tight"
  "loose"

  "pole dancing"
  "stripping"
}

set scrap_adult_power_adjectives_t {
  "jiz powered"
  "love juice powered"
  "sweat powered"
  "motion powered"
  "grunt powered"
  "cum powered"
}

set scrap_adult_construction_t {
  "dildo"
  "love doll"
  "vibrator"
  "whip"
  "melon"
  "shaft"
  "girator"
  "stroking device"
  "n0rty bits"
  "nipple tweaker"
  "underwear"
  "suction pump"
  "sheep"
  "rump"
  "penis"
  "cunt"
  "tit"
  "arse"
  "tongue"
  "lip"
  "mouth" 
  "teenager"
  "prostitute"
  "rent-boy"
  "whore"
  "wench"
  "bitch"
  "mistress" 
  "box"
  "dominatrix"
}

#create the big lists :)
set scrap_silly_qualities [concat $scrap_qualities $scrap_silly_qualities_t]
set scrap_silly_power_adjectives [concat $scrap_power_adjectives $scrap_silly_power_adjectives_t]
set scrap_silly_adjectives [concat $scrap_adjectives $scrap_silly_adjectives_t]
set scrap_silly_construction [concat $scrap_construction $scrap_silly_construction_t]

set scrap_adult_qualities [concat $scrap_qualities $scrap_adult_qualities_t]
set scrap_adult_power_adjectives [concat $scrap_power_adjectives $scrap_adult_power_adjectives_t]
set scrap_adult_adjectives [concat $scrap_adjectives $scrap_adult_adjectives_t]
set scrap_adult_construction [concat $scrap_construction $scrap_adult_construction_t]

set scrap_silly_adult_qualities [concat $scrap_qualities $scrap_silly_qualities_t]
set scrap_silly_adult_power_adjectives [concat $scrap_power_adjectives $scrap_silly_power_adjectives_t]
set scrap_silly_adult_adjectives [concat $scrap_adjectives $scrap_silly_adjectives_t]
set scrap_silly_adult_construction [concat $scrap_construction $scrap_silly_construction_t]

#duplicate for second adjectives
set scrap_silly_adjectives2 $scrap_silly_adjectives
set scrap_adult_adjectives2 $scrap_adult_adjectives
set scrap_silly_adult_adjectives2 $scrap_silly_adult_adjectives
set scrap_adjectives2 $scrap_adjectives