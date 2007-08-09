## bMotion output plugin: demon
#
# $Id: output_typos.tcl 684 2006-03-12 13:14:35Z james $
#
# vim: fdm=indent fdn=1
#
 
###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# transform things in a fashion similar to people who work at demon internet

proc bMotion_plugin_output_demon { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_demon $channel $line"


  set newLine ""
	
  #split words
	set line [string trim $line]
  set words [split $line " "]

  foreach word $words {
		regsub -all {o([b-df-hj-np-tv-xz])e(s|ing)?\M} $word {oa\1\2} word
		regsub -all {([a-z][aeiou])ck\M} $word {\1q} word
		regsub -all "don'?t" $word "doan" word
		regsub -all "didn'?t" $word "din" word
		append newLine "$word "
  }

  set line [string trim $newLine]

  return $line
}


bMotion_plugin_add_output "demon" bMotion_plugin_output_demon 0 "en"
