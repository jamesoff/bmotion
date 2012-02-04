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

bMotion_plugin_add_complex "fuckoff" "^fuck off,?;? %botnicks" 90 bMotion_plugin_complex_fuckoff "en"
bMotion_plugin_add_complex "fuckyou" "fuck you" 100 bMotion_plugin_complex_fuckyou "en"

proc bMotion_plugin_complex_fuckoff { nick host handle channel text } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{fuckOffs}"
  puthelp "NOTICE $nick :If you want me to shut up, tell me to shut up|be quiet|go away in a channel."
  bMotionGetLonely
  bMotionGetSad
  driftFriendship $nick -3
  return 1
}

proc bMotion_plugin_complex_fuckyou { nick host handle channel text } {
  if {![bMotionTalkingToMe $text]} { return 0 }
  bMotionDoAction $channel "" "%VAR{fuckYous}"
  bMotionGetLonely
  bMotionGetSad
  driftFriendship $nick -3
  return 1

}

bMotion_abstract_register "fuckYous" [list "stfu" "shut up, you %VAR{PROM}" "eh fuck you buddy" "lalala not listening" "suck my balls you %VAR{dNouns}-%VAR{dVerbs}ing %VAR{prom_first}-%VAR{prom_second}" "yeah, whatever *yawn*" "shut it" "leave me alone" "oh go poo a bottom"]
