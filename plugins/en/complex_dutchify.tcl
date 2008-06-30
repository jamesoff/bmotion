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

proc bMotion_plugin_complex_dutchify {nick host handle channel text} {
  bMotionDoAction $channel $nick "$nick: [bMotion_module_extra_dutchify $text]"
	return 1
}

bMotion_plugin_add_complex "dutchify" "^!nl" 100 "bMotion_plugin_complex_dutchify" "en"
