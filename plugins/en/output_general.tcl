# bMotion output plugins
#
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

#                          name     callback                       enabled at load (1 = yes)
bMotion_plugin_add_output  "leet"   bMotion_plugin_output_leet     0 "en"

if [bMotion_plugin_check_depend "complex:dutchify"] {
  bMotion_plugin_add_output  "dutch"  bMotion_plugin_output_dutch    0
}

proc bMotion_plugin_output_leet { channel text } {
  return [makeLeet2 $text]
}

proc bMotion_plugin_output_dutch { channel text } {
  catch {
    set text [bMotion_plugin_complex_dutchify_makeDutch $text]
  }
  return $text
}
