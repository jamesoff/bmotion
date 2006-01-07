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

bMotion_plugin_add_complex "woot" {^[a-zA-Z0-9]+[!1~]+$} 5 bMotion_plugin_complex_woot "en"

proc bMotion_plugin_complex_woot { nick host handle channel text } {
  if [regexp {^([a-zA-Z0-9]+)[!1~]+$} $text matches word] {
    bMotionDoAction $channel $word "%VAR{woots}"
		return 1
  }
}

set woots {
  "i like %%"
  "\\o/"
  "%REPEAT{3:7} %%"
  "\\o/ %%"
  "hurrah"
  "wh%REPEAT{3:7:e} %%"
  "%VAR{smiles}"
}
