# bMotion complex plugins
#
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

#                          name   regexp               chance  callback
bMotion_plugin_add_complex "test" "^%botnicks: test$"         100     "bMotion_plugin_complex_test" "en"
bMotion_plugin_add_complex "test2" "^%botnicks: test2$"         100     "bMotion_plugin_complex_test2" "en"
bMotion_plugin_add_complex "opme" "^!?op ?me$"               100     "bMotion_plugin_complex_opme" "en"


#################################################################################################################################
# Declare plugin functions

proc bMotion_plugin_complex_test { nick host handle channel text } {

   bMotionDoAction $channel $nick "%VAR{hellos}"
   bMotion_plugins_settings_set "complex:test" "blah" $channel "" $nick
   return 0
}

proc bMotion_plugin_complex_test2 { nick host handle channel text } {

   bMotionDoAction $channel $nick "%VAR{hellos} 2"
   set nick2 [bMotion_plugins_settings_get "complex:test" "blah" $channel ""]
   if {$nick2 != ""} {
     bMotionDoAction $channel $nick $nick2
   }
   return 0
}

proc bMotion_plugin_complex_opme { nick host handle channel text } {
  if [matchattr $handle |+o $channel] {
    return 0
  }
  global bMotionCache
  if {$bMotionCache(opme) == $nick} {
    #kickban instead
    newchanban $chan *!*[string range $host [string first @ $host] end] opme "op begging, 10 minute ban" 10
    return 0
  }
  putkick $channel $nick "oops, missed."
  set bMotionCache(opme) $nick
  return 0
}