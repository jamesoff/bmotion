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
  regexp -nocase "^${botnicks}:?,? (please )?(pass|hand|give) (.+)" $text matches botn please verb details
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

  # me -> user's real name
  if [string match -nocase "me" $who] {
    set whom [bMotionGetRealName $nick]
  } else {
    set whom [bMotionGetRealName $who]
  }  

  #your -> his/her
  if [string match -nocase "your *" $item] {
    set item "[getHisHers] [string range $item 5 end]"
  }
  
  if [string match -nocase "something*" $item] {
    set item "%VAR{sillyThings}"
  }
  
  bMotion_putloglev d * "bMotion: Handed $whom $item on $channel (from $nick)"
  bMotionDoAction $channel $nick "/gives $whom $item"
  bMotionGetUnLonely
  return 1
}
