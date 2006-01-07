## bMotion am not!
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

bMotion_plugin_add_complex "fry1" "i'?ve been as (dumb|stupid) as $botnicks" 100 bMotion_plugin_complex_fry1 "en"

proc bMotion_plugin_complex_fry1 {nick host handle channel text} {
	global botnicks

	bMotionDoAction $channel "" "am not %VAR{unsmiles}"

  return 1
}

