## bMotion plugin: stupid bots
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

bMotion_plugin_add_complex "stupid" "(stupid|idiot|imbecile|incompetent|loser|luser) bot" 100 bMotion_plugin_complex_stupid "en"

proc bMotion_plugin_complex_stupid { nick host handle channel text } {
  global botnicks
  if {[regexp -nocase "(stupid|idiot|imbecile|incompetent|loser|luser) bot" $text] && [regexp -nocase $botnicks $text]} {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{stupidReplies}"
    bMotionGetSad
    driftFriendship $nick -5
    return 0
  }
}