## bMotion plugin: want catcher
#
# Jolly sneaky.. if someone wants something, we'll remember it for ourselves :)
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

bMotion_plugin_add_complex "want-catch" "i (want|need) (.+)" 100 bMotion_plugin_complex_want_catcher "en"
bMotion_plugin_add_complex "mmm-catch" "^mmm+ (.+)" 100 bMotion_plugin_complex_mmm_catcher "en"
bMotion_plugin_add_complex "noun-catch" {[[:<:]](?:a|an|the) ([[:alpha:]]+)} 100 bMotion_plugin_complex_noun_catcher "en"

proc bMotion_plugin_complex_want_catcher { nick host handle channel text } {
  if [regexp -nocase "i (want|need) (?!to)(.+? )" $text matches verb item] {
    #that's a negative lookahead ---^
    bMotion_flood_undo $nick
    bMotion_abstract_add "sillyThings" $item
  }
}

proc bMotion_plugin_complex_mmm_catcher { nick host handle channel text } {
  if [regexp -nocase "^mmm+ (.+?) " $text matches item] {
    bMotion_flood_undo $nick
    bMotion_abstract_add "sillyThings" $item
  }
}

proc bMotion_plugin_complex_noun_catcher { nick host handle channel text } {
  if [regexp -nocase {[[:<:]](a|an|the|some) ([[:alpha:]]+(?!ed|ing|ce|ly))} $text matches prefix item] {
    bMotion_flood_undo $nick
    set item [string tolower $item]
    set prefix [string tolower $prefix]
    if {$prefix == "the"} {
      if {[string range $item end end] == "s"} {
        set prefix "some"
      } else {
        set prefix "a"
      }
    }
    bMotion_abstract_add "sillyThings" "$prefix $item"
  }
}