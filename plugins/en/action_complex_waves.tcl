#
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "waves" "waves (at|to) %botnicks" 100 bMotion_plugin_complex_action_waves "en"

proc bMotion_plugin_complex_action_waves { nick host handle channel text } {
  set lastGreeted [bMotion_plugins_settings_get "complex:wave" "lastGreeted" $channel ""]

  if {$lastGreeted != $handle} {
    bMotionDoAction $channel "" "/waves back"
    bMotion_plugins_settings_set "complex:wave" "lastGreeted" $channel "" $handle
    bMotionGetUnLonely
    driftFriendship $nick 1
  } else {
    if [rand 2] {
      bMotionDoAction $channel "" "%VAR{waveTooMuch}"
    }
  }
  return 1
}

bMotion_abstract_register "waveTooMuch"
bMotion_abstract_batchadd "waveTooMuch" [list "What." "Are you practicing to be the Queen or something?" "..."]
