## bMotion plugin: attack
#
# $Id$
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "attacks" "^attacks (.+) with " 100 bMotion_plugin_complex_action_attack "en"

proc bMotion_plugin_complex_action_attack { nick host handle channel text } {  
  if {![bMotion_interbot_me_next $channel]} { return 1 }
  set damage [rand 1500]
  regexp -nocase "^attacks (.+) with (.+)" $text matches who item
  set who [bMotionGetRealName $who]
  regexp -nocase "(an?|the|some|his|her) (.+)" $item matches blah item
  bMotion_plugins_settings_set "complex:attacks" "who" "" "" $who
  bMotion_plugins_settings_set "complex:attacks" "item" "" "" $item
  bMotion_plugins_settings_set "complex:attacks" "score" "" "" $damage
  bMotionDoAction $channel $nick "%VAR{attack_responses}"
  return 1
}

set attack_responses {
  "%% attacks %SETTING{complex:attacks:who:_:_} with '%SETTING{complex:attacks:item:_:_}' for %SETTING{complex:attacks:score:_:_} damage."
  "%SETTING{complex:attacks:who:_:_} takes %SETTING{complex:attacks:score:_:_} damage from %OWNER{%%} '%SETTING{complex:attacks:item:_:_}'"
  "%SETTING{complex:attacks:who:_:_} is tremendously damaged by the %SETTING{complex:attacks:item:_:_} and takes %SETTING{complex:attacks:score:_:_} damage!"
  "MISS!"
  "%SETTING{complex:attacks:who:_:_} is immune to '%SETTING{complex:attacks:item:_:_}'"
  "%SETTING{complex:attacks:who:_:_} absorbs the damage and gains %SETTING{complex:attacks:score:_:_} HP!"
}
bMotion_abstract_register "attack_responses"
bMotion_abstract_batchadd "attack_responses" $attack_responses
