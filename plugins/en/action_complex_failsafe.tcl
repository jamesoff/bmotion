## bMotion plugin: away handler

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




bMotion_plugin_add_action_complex "zzz-failsafe" {^(.+?)s %botnicks} 100 bMotion_plugin_complex_action_failsafe "en"


proc bMotion_plugin_complex_action_failsafe { nick host handle channel text } {

  regexp {^(.+?)s } $text matches verb

  if {$verb == ""} {
    return 1
  }

  bMotionDoAction $channel $verb "%VAR{failsafes}"
}


bMotion_abstract_register "failsafes"
bMotion_abstract_batchadd "failsafes" [list "%VAR{rarrs}" "%REPEAT{3:7:m} %%" "%VAR{thanks}" "i do love a good %%ing"]
