#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) 2011
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_output "homophone" bMotion_plugin_output_homophone 1 "en" 98


#
# sometimes replace words with their homophones
# code mostly stolen from output_colloquial.tcl
#
proc bMotion_plugin_output_homophone { channel line } {
  global bMotionSettings

  set homophone_rate $bMotionSettings(homophone)
  set oldLine $line

  set newLine ""
  set words [split $line { }]
  # set words [regexp -all -inline {\S+} $line]

  set homList [bMotion_abstract_all homophones]

  foreach word $words {
    if {[bMotion_plugin_output_homophone_chance $homophone_rate]} {
    
      bMotion_putloglev 1 * "trying to trigger homophone on $word"
      
      # we might want to replace this word. iterate through all homophone sets.
      
      foreach homSet $homList {
        set homItems [split $homSet ":"]
        
        bMotion_putloglev 1 * "working with $homSet"
        
        set haveReplaced 0
        
        foreach item $homItems {
          # only try to keep replacing things if we haven't done so yet, to avoid cyclical replacements
          if {$haveReplaced == 0} {
            # is it a word we can replace, possibly with some punctuation around it?
            if {[regexp -nocase "^\[\\\,\\\:\\\;\\\.\\\!\\\?\\\-\\\"\\\'\]*($item)\[\\\,\\\:\\\;\\\.\\\!\\\?\\\-\\\"\\\'\]*$" $word fullWord cleanWord]} {
            
              # found a match! replace with a random word from the list
            
              bMotion_putloglev 1 * "$word matches $item, cleanWord is $cleanWord"
            
              set newWord [pickRandom $homItems]
              while { [string equal -nocase $cleanWord $newWord] } {
                set newWord [pickRandom $homItems]
              }
            
              set haveReplaced 1
            
              # now just change the word and it will be output below
              regsub -all -nocase "\\\w\+" $word $newWord word
            
              bMotion_putloglev 1 * "leaving with $word"
            }
          }
        }
      }
    }
    append newLine "$word "
  }
  set line $newLine

  #don't waste time updating if the line didn't change
  if {$line == $oldLine} {
    return $oldLine
  }

  return [string trim [bMotionDoInterpolation $line "" ""]]
}

#random chance test
proc bMotion_plugin_output_homophone_chance { freq } {
  if {[rand 1000] <= $freq} {
    return 1
  }
  return 0
}

# the abstract contains lists of words that sound exactly or mostly like
# each other; if one in the group is found, it may be replaced with any
# other in the group
#
# cherry-picked most of them from homophone.com
bMotion_abstract_register "homophones" {
  "aye:eye:I"
  "air:heir"
  "aural:oral"
  "be:bee"
  "bear:bare"
  "bazaar:bizarre"
  "bean:been"
  "blew:blue"
  "boar:bore"
  "bored:board"
  "borough:burrow"
  "brake:break"
  "braking:breaking"
  "sea:see"
  "Czech:check:cheque"
  "carat:caret:carrot:karat"
  "cede:seed"
  "ceding:seeding"
  "ceil:seal"
  "ceiling:sealing"
  "cents:scents:sense"
  "censer:censor:senser:sensor"
  "cent:scent:sent"
  "sear:seer"
  "cereal:serial"
  "cheap:cheep"
  "chews:choose"
  "chili:chile:chilly"
  "clause:claws"
  "coarse:course"
  "cocks:cox"
  "colonel:kernel"
  "come:cum"
  "cue:q:queue"
  "dam:damn"
  "dammed:damned"
  "days:daze"
  "dear:deer"
  "desert:dessert"
  "die:dye"
  "died:dyed"
  "discrete:discreet"
  "do:doe:dough"
  "dyeing:dying"
  "eight:ate"
  "eunuchs:unix"
  "finish:Finnish"
  "faery:faerie:fairy"
  "flair:flare"
  "flour:flower"
  "for:fore:four"
  "foul:fowl"
  "Greece:grease"
  "gaze:gays"
  "gin:djinn"
  "gnu:knew:new"
  "gnus:news"
  "gorilla:guerilla"
  "grade:grayed"
  "grisly:grizzly"
  "guise:guys"
  "hair:hare"
  "hear:here"
  "heard:herd"
  "hoar:whore"
  "hoard:horde:whored"
  "horse:whores:hoarse"
  "hole:whole"
  "hour:our"
  "hours:ours"
  "house:how's"
  "ink:Inc."
  "i'll:aisle:isle"
  "instants:instance"
  "knead:need"
  "kneaded:needed"
  "knight:night"
  "lacks:lax"
  "leak:leek"
  "leaks:leeks"
  "licker:liquor:lick 'er"
  "links:lynx"
  "loot:lute"
  "Maine:main:mane"
  "Marx:marks"
  "made:maid"
  "mail:male"
  "mails:males"
  "email:emale"
  "emails:emales"
  "e-mail:e-male"
  "e-mails:e-males"
  "manner:manor"
  "or:ore:oar"
  "oars:ores"
  "pain:pane"
  "pair:pare:pear"
  "pause:paws"
  "peace:piece:peas"
  "pie:pi"
  "plain:plane"
  "presence:presents"
  "profit:prophet"
  "pea:pee"
  "Rome:roam"
  "rap:wrap"
  "raps:wraps"
  "rapper:wrapper"
  "rapped:wrapped:rapt"
  "rapping:wrapping"
  "right:rite:write:wright"
  "rights:rites:writes:wrights"
  "rye:wry"
  "sail:sale"
  "sails:sales"
  "seamen:semen"
  "seas:sees:seize"
  "sects:sex:secks"
  "soar:sore"
  "symbol:cymbal"
  "symbols:cymbals"
  "waist:waste"
  "waisted:wasted"
  "weak:week"
  "weakly:weekly"
  "which:witch"
  "whine:wine"
  "wood:would"
  "you:yew"
  "bury:berry"
  "wheat:weed"
  "meet:meat:mete"
  "meets:meats:metes"
  "where:wear"
}
