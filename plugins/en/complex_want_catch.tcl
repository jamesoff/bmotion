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
bMotion_plugin_add_complex "mmm-catch" "^mm+[,\. ]*(.+)" 100 bMotion_plugin_complex_mmm_catcher "en"
bMotion_plugin_add_complex "plusplus-catch" {^(.+)\+{2}$} 100 bMotion_plugin_complex_mmm_catcher "en"
bMotion_plugin_add_complex "noun-catch" {[[:<:]](?:a|an|the) ([[:alpha:]]+)} 100 bMotion_plugin_complex_noun_catcher "en"

proc bMotion_plugin_complex_want_catcher { nick host handle channel text } {
  if [regexp -nocase "i (want|need) (?!to)(.+? )" $text matches verb item] {
    #that's a negative lookahead ---^
    bMotion_flood_undo $nick
    bMotion_abstract_add "sillyThings" $item
    if {[rand 100] > 95} {
    	bMotionDoAction $channel "" "%VAR{gotone}"
    }
	}
}

proc bMotion_plugin_complex_mmm_catcher { nick host handle channel text } {
  if [regexp -nocase "^mm+\[,\\.\]* (.+)(\\+{2})?" $text matches discard1 item] {
    bMotion_flood_undo $nick
    bMotion_abstract_add "sillyThings" $item
	
		if {[rand 100] > 85} {
				bMotionDoAction $channel $item "%VAR{betters}"
		}
	}
}

proc bMotion_plugin_complex_noun_catcher { nick host handle channel text } {
  if [regexp -nocase {[[:<:]](a|an|the|some) ([[:alpha:]]+)( [[:alpha:]]+[[:>:]])?} $text matches prefix item second] {
    bMotion_flood_undo $nick
    set item [string tolower $item]

    if [regexp "(ly)$" $item] {
      return 0
    }

    if [regexp "(ing|ed)$" $item] {
      if {$second == ""} {
        return 0
      }
      append item $second
    }

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

bMotion_abstract_register "gotone"
bMotion_abstract_batchadd "gotone" [list "I've already got one%|%BOT\[are you sure?\]%|yes yes, it's very nice" "I already have one of those."]

bMotion_abstract_register "betters"
bMotion_abstract_batchadd "betters" [list "mm%REPEAT{1:5:m}, %VAR{sillyThings}{strip}" "%VAR{sillyThings}{strip} > %%" "%% < %VAR{sillyThings}{strip}" "%%++"]
