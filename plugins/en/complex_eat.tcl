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

bMotion_plugin_add_complex "eat" "^%botnicks,?:? (please)?eat " 100 bMotion_plugin_complex_eat "en"

proc bMotion_plugin_complex_eat { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^${botnicks},?:? (please)?eat (.+)" $text ming ming1 ming2 details] {
    bMotionDoAction $channel $nick "/eats $details"
    if [regexp -nocase $botnicks $details] {
      bMotionDoAction $channel "" "mmmmm... recursive"
    }
    bMotionGetUnLonely
    return 1
  }
}
