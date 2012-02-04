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

bMotion_plugin_add_complex "unf" "((~(rarr|oof|unf)~)|unf|lick(s)?) %botnicks" 100 bMotion_plugin_complex_unf "en"

proc bMotion_plugin_complex_unf { nick host handle channel text } {
  set bodyPaintNick [bMotion_plugins_settings_get "complexaction:hands" "paint_nick" "" ""]
  set bodyPaintChannel [bMotion_plugins_settings_get "complexaction:hands" "paint_channel" "" ""]

  if {$bodyPaintNick != "" && $bodyPaintChannel == $channel && $nick == $bodyPaintNick} {
    bMotionDoAction $channel $bodyPaintNick "OOoooooooooooo thanks %%, thats some good tongue action"
    bMotion_plugins_settings_set "complexaction:hands" "paint_nick" "" "" ""
    bMotion_plugins_settings_set "complexaction:hands" "paint_channel" "" "" ""
  }
  bMotionGetHorny
  return 2
}
