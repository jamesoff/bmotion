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
	if {[regexp -nocase "(shows) $botnicks (a|an|the|some|his|her)? ?(.+)" $text bling act bot preposition item]} {
	  bMotion_putloglev d * "bMotion: Was shown !$item! by $nick in $channel"

    #catch everything for now
    bMotionDoAction $channel $item "%VAR{show_generic}"
    
    #we'll add it to our random things list for this session too
    bMotion_abstract_add "sillyThings" $item
    return 1
  } 
  #end of "hands" handler
}


# supporting functions

# abstracts

bMotion_abstract_register "show_amazements"
bMotion_abstract_batchadd "show_amazements" {
  "amazement"
  "astonishment"
  "wonderment"
  "mystification"
}

bMotion_abstract_register "show_whoas"
bMotion_abstract_batchadd "show_whoas" {
  "whoa"
  "wow"
  "wh%REPEAT{3:6:e}"
  "my word"
  "I say"
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
  "%REPEAT{3:6:o}h, %VAR{show_adjectives}!%|/steals %% and runs off%|ALL MINE NOW%colen"
  "now that's %VAR{show_adjectives}"
  "p%REPEAT{2:5:f}t.. wait until you see my %VAR{sillyThings}{strip}"
  "/takes a picture"
}
