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

bMotion_plugin_add_output "ebonics" bMotion_plugin_output_ebonics 0 "en" 11


proc bMotion_plugin_output_ebonics { channel line } {
  set line [string trim $line]

  set newline ""
  set words [split $line " "]

  foreach word $words {
		if [regexp -nocase {^([aeiou]?[^aeiou]+[aeiou])\w{2,}$} $word matches first] {
			set word "${first}zzle"
		}

		set word [string map -nocase {for fo} $word]

		append newline "$word "
		
  }

  return $newline
}
