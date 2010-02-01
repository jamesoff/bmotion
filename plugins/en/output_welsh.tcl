#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_output "welsh" bMotion_plugin_output_welsh 0 "en" 11


proc bMotion_plugin_output_welsh { channel line } {
  set line [string trim $line]

  set newline ""
  set words [split $line " "]

#1533.18  [+     Duds] makie - take out all vowells
#1533.24  [+     Duds] now randomise the order of all remaining letters
#1533.27  [+     Duds] like that
#1533.41  [+    makie] lol
#1534.13  [+     Duds] it should also double the first letter frequently for no reason

  foreach word $words {
		#not for one letter words
		if {[string length $word] == 1} {
			append newline "$word "
			continue
		}

		#fix words starting /
		set startSlash 0
		if {[string range $word 0 0] == "/"} {
			set startSlash 1
			set word [string range $word 1 end]
		}

		if {![regexp -nocase {^[a-z0-9']+$} $word]} {
			append newline "$word "
			continue
		}

		#delete the vowels
		regsub -nocase -all {[aeiou]} $word "" word

		#randomise letters
		if [regexp -nocase {^[a-z]+$} $word] {
			set letters [split $word {}]
			set newword ""
			while {[llength $letters] > 0} {
				set index [rand [llength $letters]]
				append newword [lindex $letters $index]
				set letters [lreplace $letters $index $index]
			}
		} else {
			set newword $word
		}

		#possibly double the first letter
		if {[rand 4] > 2} {
			regsub -nocase "^(.)" $newword "\\1\\1" newword
		}

		if {$startSlash == 1} {
			set newword "/$newword"
		}

		append newline "$newword "
		
  }

  return $newline
}
