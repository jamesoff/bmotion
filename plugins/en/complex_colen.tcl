# bMotion plugin: colen$(£&$
#
# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "colen" {^[!\"£\$%\^&\*\(\)\@\#]{3,}} 40 bMotion_plugin_complex_colen "all"

proc bMotion_plugin_complex_colen { nick host handle channel text } {
  if [regexp {^\*\*\*} $text] {
    return 0
  }
  if [bMotion_interbot_me_next $channel] {
    bMotionDoAction $channel $nick [bMotionGetColenChars]
  }
  return 1
}

