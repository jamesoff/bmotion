## bMotion grammar nazi
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

bMotion_plugin_add_complex "nazi-your" "^your (a |the )?[a-z]+$" 40 bMotion_plugin_complex_nazi1 "en"

proc bMotion_plugin_complex_nazi1 {nick host handle channel text} {

  if {![bMotion_interbot_me_next $channel]} {
  	return 1
  }

	bMotionDoAction $channel $nick "%VAR{nazi1}"
  return 1
}

bMotion_abstract_register "nazi1"
bMotion_abstract_batchadd "nazi1" [list "%%: \"you're\"" "their what?" "s/your/you're/"]

