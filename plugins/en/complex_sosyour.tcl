## bMotion so's your face plugin
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

bMotion_plugin_add_complex "sosyour" "(it'?s|it is|you'?re|s?he'?s|they'?re) (a|the) \[^ \]+$" 100 bMotion_plugin_complex_sosyour "en"

proc bMotion_plugin_complex_sosyour {nick host handle channel text} {
	global botnicks

  if {![bMotion_interbot_me_next $channel]} {
  	return 1
  }

	if [regexp -nocase "^($botnicks\[:, \]+)?(it'?s|it is|you'?re|s?he'?s|they'?re) (a|the) (\[a-z\]+)\[.!\]?$" $text matches botnickused bn article noun] {
    if {$botnickused == ""} {
			if {[rand 100] < 95} {
				return 0
			}
		}
		bMotionDoAction $channel $nick "%VAR{sosyours}" "$article $noun"
		return 1
  }
  return 0
}

bMotion_abstract_register "sosyours"
bMotion_abstract_batchadd "sosyours" [list "so's your face" "you're %2"]

