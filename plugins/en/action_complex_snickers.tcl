## bMotion plugin: smacks
#
# $Id$

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "snickers" "^snicker" 50 bMotion_plugin_complex_action_snickers "en"

proc bMotion_plugin_complex_action_snickers { nick host handle channel text } {
  if [regexp -nocase "^snicker(s)?" $text ming pop] {
    set response "/%VAR{chocolates}$pop"
    bMotionDoAction $channel $nick $response
    return 1
  }
}