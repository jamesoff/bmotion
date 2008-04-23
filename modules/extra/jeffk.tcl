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

proc bMotion_module_extra_jeffk { line } {
  set line [string map -nocase {"hello" "helko" "n\'t" "ant" "sy" "sey" "is" "si"} $line]
  set line [string map -nocase {"like" "liek" "you" "yuo" "site" "siet" "body" "bodey"} $line]
  set line [string map -nocase {"taken" "taken" "ter" "tar" "make" "maek" "number" "%VAR{jeffk_number}"} $line]
  set line [string map -nocase {"name" "naem" "ll" "l" "ly" "ley"} $line]
  set line [string map -nocase {"ble" "bal" "word" "wrod" "inter" "intar" "lay" "alay" "luck" "luick" "here" "hear"} $line]

	# broken!
  #set line [string map {"!" "%REPEAT{2:5:!}"} $line]
  #set line [string map {"?" "%REPEAT{2:5:?}"} $line]

  if {![rand 8]} {
    append line " %VAR{jeffk_ends}"
  }

  set line [bMotionDoInterpolation $line "" "" ""]
  set line [bMotionInterpolation2 $line]

	if {![rand 6]} {
		set line [string toupper $line]
	} else {
		set words [split $line " "]
		set newline ""
		foreach word $words {
			set word [string map -nocase { "you're" "%VAR{jeffk_ur}" "your" "%VAR{jekkf_ur}"} $line]
			set word [string map -nocase { "their" "%VAR{jeffk_thr}" "there" "%VAR{jeffk_thr}" "they're" "%VAR{jeffk_thr}"} $line]

			if {([string length $word] > 5) && (![rand 6])} {
				set letters [split $word {}]
				set newword ""
				set first_letter [lindex $letters 0]
				set last_letter [lindex $letters end]
				set letters [lrange 1 end-1]
				while {[llength $letters] > 0} {
					set index [rand [llength $letters]]
					append newword [lindex $letters $index]
					set letters [lreplace $letters $index $index]
				}
				set word "$first_letter$newword$last_letter"
			}

			if {![rand 3]} {
				append newline [string toupper $word]
			}
			else {
				append newline $word
			}
			append newline " "
		}
		set line $newline
	}

  if {![rand 10]} {
    append line " %VAR{jeffk_ends}"
  }

	set line [bMotionDoInterpolation $line "" "" ""]
  return $line
}

set jeffk_number { "numbar" "number" }
set jeffk_ends {"wtf" "lol" "omg" "omg lol" "lol wtf" "faggot" "fagott" "hairy"}
set jeffk_ur { "you''re" "your" "you're" }
set jeffk_thr { "their" "there" "they're" "they''re" "theyre" }
