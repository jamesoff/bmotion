## bMotion output plugin: gollum
#

#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


proc bMotion_plugin_output_gollum { channel line } {
  if {([string length $line] > 10) && ([rand 100] > 97)} {
    set line [string trim $line]
    if {![regexp {[.!?]$} $line]} {
      append line "."
    }
    append line " %VAR{preciouses}"

    set line [bMotionDoInterpolation $line "" "" $channel]
  }
  return $line
}

set preciouses {
  "my precious"
  "precious"
  "preciouses"
  "the precious"
}

bMotion_plugin_add_output "gollum" bMotion_plugin_output_gollum 1 "all"