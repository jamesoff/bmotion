# bMotion complex plugin: smiley
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

bMotion_plugin_add_complex "smiley" {^[;:=]-?[)D>]$} 40 bMotion_plugin_complex_smiley "all"
bMotion_plugin_add_complex "smiley2" {^([\-^])[_-]*[\-^];*$} 40 bMotion_plugin_complex_smiley "all"
bMotion_plugin_add_complex "smiley3" {^heh(ehe?)*$} 30 bMotion_plugin_complex_smiley "all"

proc bMotion_plugin_complex_smiley { nick host handle channel text } {  
  global mood

  if {![bMotion_interbot_me_next $channel]} { return 0 }

  if {$mood(happy) < 0} {
    return 0
  }

  bMotionDoAction $channel "" "%VAR{smiles}"
  bMotionGetHappy
  bMotionGetUnLonely
  return 1
}
