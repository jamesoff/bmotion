## bMotion plugin: hug
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

bMotion_plugin_add_complex "hug" "%botnicks hug " 100 bMotion_plugin_complex_hug "en"

proc bMotion_plugin_complex_hug { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^$botnicks hug (.+)" $text matches bn item] {
    bMotion_plugin_complex_hug_do $channel $item $host
    return 1
  }
}

proc bMotion_plugin_complex_hug_do { channel nick host } {
  if [bMotionIsFriend $nick] {
    set nick [bMotionTransformNick $nick $nick $host]
    bMotionGetUnLonely
    bMotionGetHappy
    bMotionDoAction $channel $nick "%VAR{hugs}"
  } else {
    bMotionDoAction $channel $nick "%VAR{blehs}"
  }
}
