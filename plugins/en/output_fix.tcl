## bMotion output plugin: colloquial
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

bMotion_plugin_add_output "fix" bMotion_plugin_output_fix 1 "all"


#  Fix broken output
#
proc bMotion_plugin_output_fix { channel line } {
	set original_line $line
  regsub -nocase {\$var} $line "%VAR" line
  regsub -nocase {%pickuser\[[^]]+\]} $line "" line
  if {$line != $original_line} {
		set line [bMotionDoInterpolation $line "" "" $channel]
  }
  return $line
}
