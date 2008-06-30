## bMotion pack of highly
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

bMotion_plugin_add_complex "pack" {a ([a-z]+ (of )?[a-z]+ly) [a-z]+ed [a-z]+} 100 bMotion_plugin_complex_pack "en"

proc bMotion_plugin_complex_pack {nick host handle channel text} {
	global botnicks

  if {![bMotion_interbot_me_next $channel]} {
  	return 2
  }

	if [regexp -nocase {a ([a-z]+ (of )?[a-z]+ly) [a-z]+ed [a-z]+} $text matches pop] {
		bMotionDoAction $channel $pop "%%, got it."
		return 1
  }
  return 0
}

