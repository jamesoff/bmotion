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
  set line [string map {"!" "%REPEAT{1:5:!}%REPEAT{0:2:1}"} $line]
  set line [string map {"?" "%REPEAT{1:5:?}%REPEAT{0:2:/}"} $line]
  
  if {![rand 4]} {
    append line " %VAR{jeffk_ends}"
  }

  set line [bMotionDoInterpolation $line "" "" ""]
  set line [bMotionInterpolation2 $line]

  if {![rand 5]} {
    set line [string toupper $line]
  }

  if {![rand 4]} {
    append line " %VAR{jeffk_ends}"
    set line [bMotionDoInterpolation $line "" "" ""]
  }

  return $line
}

set jeffk_number { "numbar" "number" }

set jeffk_ends {"wtf" "lol" "omg" "omg lol" "lol wtf" "faggot" "fagott" "hairy"}