## bMotion plugin: uNF
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

bMotion_plugin_add_complex "unf" "((~(rarr|oof|unf)~)|unf|lick(s)?) %botnicks" 100 bMotion_plugin_complex_unf "en"
  
proc bMotion_plugin_complex_unf { nick host handle channel text } {
  bMotionGetHorny
  return 1
}
