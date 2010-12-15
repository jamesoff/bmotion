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

bMotion_plugin_add_output "english" bMotion_plugin_output_english 1 "en" 13


#    Tries to straighten out b0rk3d English
#

proc bMotion_plugin_output_english { channel line } {
  set line [string trim $line]

  # me at start of line is WRONG
  #
  # me ___s --> /me
  # me __[^s] --> I
  
  if [regexp -nocase {^me ([^ ]+) (.+)} $line matches first rest] {
    bMotion_putloglev 2 * "bMotion: output:english detected a me* line"
    if [regexp -nocase "s$" $first] {
      #use /me
      set line "/$first $rest"
    } else {
      #use I
      set line "I $first $rest"
    }
  }


  #"a" before a vowel needs to be "an"
  regsub -nocase -all {\m(a) ([aeiou].+)\M} $line {\1n \2} line

	#"an" before a cons... cont... non-vowel needs to be "a"
	regsub -nocase -all {[[:<:]](an) ([^aeiou][a-z]+)[[:>:]]} $line {a \2} line

	# a(n) before a number is wrong more often than it is right
	regsub -nocase -all {an? ([0-9]+)} $line {\1} line

	#"a an" and "an a" are wrong
	regsub -nocase -all "(a an|an a) " $line "" "a"

  if {[rand 100] > 60} {
    #captials at start, . at end
    if [regexp {^([a-z])(.+)} $line matches first rest] {
			if {!([string range $line 0 1] == "r ")} {
				set line "[string toupper $first]$rest"
			}
    }

    if [regexp -nocase {^[a-z].*[^:][a-z0-9]$} $line] {
      append line "."
    }
  }

	regsub -all "an? some" $line "some" line

	regsub -all "you is " $line "you are " line

	regsub -all "the an? " $line "the " line

	regsub -all "(an?) (his|her|the)" $line "\\1 " line

	#fix double (or more) spaces
	regsub -all "  +" $line " " line

	#fix double-period at end of line
	regsub -all "\[^.\]\\.\\.$" $line "." line

	regsub -all {\myou is\M} $line "you are" line

	#fix gap before full stop

	#TODO: fix
	regexp -all { +\\.} $line "." line

	# fix american spellings
	# TODO: make this an option or US bots can talk wrong english and UK bots can talk right english
	set line [string map -nocase { color colour neighbor neighbour aluminum aluminium favorite favourite center centre } $line]

  return $line
}
