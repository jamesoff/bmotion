## bMotion complex plugin: hands
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "shows" "(shows) %botnicks " 100 bMotion_plugin_complex_action_shows "en"

proc bMotion_plugin_complex_action_shows { nick host handle channel text } {
  global botnicks
	if {[regexp -nocase "(shows) $botnicks (a|an|the|some|his|her|its)? ?(.+)" $text bling act bot preposition item]} {
	  bMotion_putloglev d * "bMotion: Was shown !$preposition $item! by $nick in $channel"

	  if {($preposition == "a") || ($preposition == "an") || ($preposition == "some")}
      {
	    set properitem "the $item"
	    set learnitem "$preposition $item"
	  }
      else
      {
        if {$preposition == "the"}
        {
          set properitem "the $item"
          set learnitem "$item" # not pretty, but oh well.
        }
        else
        {
          # his, her or its
          if {(([bMotionGetGender $nick $host] == "male") && ($preposition == "his")) ||
              (([bMotionGetGender $nick $host] == "female") && ($preposition == "her"))}
          {
            set realname [bMotionGetRealName $nick $host]
            set properitem "%OWNER{$realname} $item"
            # adds a bit of flavour to sillyThings:
            set learnitem "$properitem"
          }
          else
          {
            set properitem "the $item"
            set learnitem "$item" # not pretty, but oh well.
          }
        }
      }
      
      bMotion_putloglev d * "bMotion: going to do stuff with !$properitem! and learn !$learnitem!"

    #catch everything for now
    bMotionDoAction $channel $properitem "%VAR{show_generic}"

    #we'll add it to our random things list for this session too
    bMotion_abstract_add "sillyThings" $learnitem
    return 1
  }
  #end of "shows" handler
}


# supporting functions

# abstracts

bMotion_abstract_register "show_amazements"
bMotion_abstract_batchadd "show_amazements" {
  "amazement"
  "astonishment"
  "wonderment"
  "mystification"
  "shock"
  "surprise"
}

bMotion_abstract_register "show_whoas"
bMotion_abstract_batchadd "show_whoas" {
  "whoa"
  "wow"
  "wh%REPEAT{3:6:e}"
  "my word"
  "I say"
  "hohoho"
}

bMotion_abstract_register "show_comparisons"
bMotion_abstract_batchadd "show_comparisons" {
  "bigger"
  "smaller"
  "longer"
  "shorter"
  "colder"
  "warmer"
  "shinier"
  "sillier"
  "harder"
  "more expensive"
  "a lot more entertaining"
  "almost better"
  "sexier"
  "going to hurt more"
  "wobblier"
  "softer"
}

bMotion_abstract_register "show_adjectives"
bMotion_abstract_batchadd "show_adjectives" {
  "shiny"
  "pretty"
  "colourful"
  "cute"
  "impressive"
  "silly"
  "perfect"
}

bMotion_abstract_register "show_generic"
bMotion_abstract_batchadd "show_generic" {
  "/gasps in %VAR{show_amazements}"
  "%VAR{show_whoas}%colen"
  "%VAR{show_whoas}.. that's %VAR{show_comparisons} than %VAR{sillyThings}!"
  "%REPEAT{3:6:o}h, %VAR{show_adjectives}!%|/steals %% and runs off%|ALL MINE NOW%colen%|/sells %% on ebay"
  "now that's %VAR{show_adjectives}"
  "p%REPEAT{2:5:f}t.. wait until you see my %VAR{sillyThings}{strip}"
  "/takes a picture"
  "/contemplates%|it'd be nicer if it had %PLURAL{%VAR{sillyThings}{strip}}"
  "I prefer %OWNER{%ruser}"
  "/admires %%"
  "/replaces %% with a cheap %VAR{colours} plastic copy%|bwaha%REPEAT{1:4:ha}"
}
