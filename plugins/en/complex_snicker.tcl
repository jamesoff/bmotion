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

bMotion_plugin_add_complex "snicker" "\\\*snickers?\\\*" 50 bMotion_plugin_complex_snickers "en"

proc bMotion_plugin_complex_snickers { nick host handle channel text } {
  if [regexp -nocase "\\\*snicker(s)?\\\*" $text ming pop] {
    bMotionDoAction $channel "" "*%VAR{chocolates}$pop*"
    return 1
  }
}
