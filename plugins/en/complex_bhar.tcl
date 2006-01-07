## bMotion plugin: bhar (etc)
#
# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "bhar" "^((((a|(bo*)|(gro+))r*)*ha?r+)|(ar+)( $botnicks)?)$" 50 bMotion_plugin_complex_bhar "en"

proc bMotion_plugin_complex_bhar { nick host handle channel text } {
  set arr [bMotion_plugins_settings_get "complex:bhar" "contents" $channel $nick]
  if {$arr == ""} {
    bMotion_plugins_settings_set "complex:bhar" "contents" $channel $nick $text
    bMotionDoAction $channel $nick "%VAR{arrs}"
		return 1
  }  
}

set arrs {
  "bhar"
  "boohar"
  "a%REPEAT{3:5:r}ha%REPEAT{3:6:r}"
  "r"
  "a%REPEAT{2:5:r}"
  "graha%REPEAT{3:5:r}"
  "bhar %%"
  "boohar %%"
  "a%REPEAT{3:5:r}ha%REPEAT{3:6:r} %%"
  "r %%"
  "a%REPEAT{2:5:r} %%"
  "graha%REPEAT{3:5:r} %%"
}
