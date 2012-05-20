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

bMotion_plugin_add_output "colloq" bMotion_plugin_output_colloq 1 "en" 11


#    Attempt to make contractions etc similar to real people
#
proc bMotion_plugin_output_colloq { channel line } {
  global bMotionSettings

  set colloq_rate $bMotionSettings(colloq)
  set oldLine $line

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "\mshould( have|\'ve| of)\M" $line [bMotion_abstract_get "colloq_shouldhave"] line
		if {$line == ""} {
			putlog "colloq plugin killed output: 1"
		}
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "\mshouldn't( have|\'ve| of)\M" $line [bMotion_abstract_get "colloq_shouldhavenot"] line
		if {$line == ""} {
			putlog "colloq plugin killed output: 2"
		}
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "sort of" $line "sorta" line
    regsub -all -nocase "something" $line "sommat" line
		if {$line == ""} {
			putlog "colloq plugin killed output: 3"
		}
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "cheap" $line "cheep" line
    regsub -all -nocase "seam" $line "seem" line
    regsub -all -nocase "mean" $line "meen" line
		if {$line == ""} {
			putlog "colloq plugin killed output: 4"
		}
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "exactly" $line "exactily" line
    regsub -all -nocase "separate" $line "seperate" line
    regsub -all -nocase "definitely" $line "definately" line
		if {$line == ""} {
			putlog "colloq plugin killed output: 5"
		}
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase {\myou\M} $line [bMotion_abstract_get "colloq_you"] line
    regsub -all -nocase {\myour\M} $line [bMotion_abstract_get "colloq_your"] line
		if {$line == ""} {
			putlog "colloq plugin killed output: 6"
		}
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "n't" $line "nt" line
		if {$line == ""} {
			putlog "colloq plugin killed output: 7"
		}
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    if {[regexp -nocase "\[a-z0-9\]{2}$" $line]} {
      append line "."
    }
  }

  #let's break some words
  set newLine ""
  set words [split $line { }]
  foreach word $words {
    if {[bMotion_plugin_output_colloq_chance $colloq_rate]} {
      regsub -nocase {\m(dis|anti|un|im)} $word [bMotion_abstract_get "colloq_negative"] word
    }
    append newLine "$word "
  }
  set line $newLine
		if {$line == ""} {
			putlog "colloq plugin killed output: 8"
		}

  #don't waste time updating if the line didn't change
  if {$line == $oldLine} {
    return $oldLine
  }

	if {$line == ""} {
		putlog "colloq plugin recovering output"
		return $oldLine
	}

  return [string trim [bMotionDoInterpolation $line "" ""]]
}

#random chance test
proc bMotion_plugin_output_colloq_chance { freq } {
  if {[rand 1000] <= $freq} {
    return 1
  }
  return 0
}

bMotion_abstract_register "colloq_shouldhave" {
  "should've"
  "should of"
}

bMotion_abstract_register "colloq_shouldhavenot" {
  "shouldnt've"
  "shouldn't of"
  "shouldnt of"
  "shouldnt have"
}

bMotion_abstract_register "colloq_you" {
  "u"
  "ya"
}

bMotion_abstract_register "colloq_your" {
  "ur"
}

bMotion_abstract_register "colloq_negative" {
  "dis"
  "un"
  "anti"
  "im"
}
