## bMotion plugin: hand
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

bMotion_plugin_add_complex "hand" "^%botnicks:?,? (please )?(pass|hand|give) (.+)" 100 bMotion_plugin_complex_hand "en"

proc bMotion_plugin_complex_hand { nick host handle channel text } {
  global botnicks
  regexp -nocase "^${botnicks}:?,? (please )?(pass|hand|give) (.+)" $text ming blah1 blah2 blah2 details
  set who [string trim [string range $details 0 [string first " " $details]]]
  set item [string range $details [expr [string first " " $details] + 1] [string length $details]]

  if {[regexp -nocase "blow job|fuck|shag" $item]} {
    #TODO: add bMotionLike here
    bMotionDoAction $channel "" "No."
    return 1
  }

  if [regexp -nocase {[[:<:]](hug|cuddle|knuffel)[[:>:]]} $item] {
    #we're being asked to hug someone
    if [bMotion_plugin_check_depend "complex:hug"] {
      bMotion_plugin_complex_hug_do $channel $who $host
    } else {
      bMotionDoAction $channel $nick "%%: I'm sorry, I don't know how to hug %VAR{unsmiles}"
    }
    return 1
  }

  set whom [bMotionTransformNick $who $nick $host]

  #your -> his/her
  if [string match -nocase "your *" $item] {
    set item "[getHisHers] [string range $item 5 end]"
  }
  bMotion_putloglev d * "bMotion: Handed $whom $item on $channel (from $nick)"
  bMotionDoAction $channel $nick "/gives $whom $item"
  bMotionGetUnLonely
  return 1
}