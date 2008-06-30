## bMotion grammar nazi
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

bMotion_plugin_add_complex "nazi-your" "^your (a |the )?\[a-z\]+$" 60 bMotion_plugin_complex_nazi1 "en"
bMotion_plugin_add_complex "nazi-regexp" "^s/\[^/\]+/\[^/\]+$" 80 bMotion_plugin_complex_nazi2 "en"

proc bMotion_plugin_complex_nazi1 {nick host handle channel text} {

  if {![bMotion_interbot_me_next $channel]} {
  	return 1
  }

	bMotionDoAction $channel $nick "%VAR{nazi1}"
  return 1
}

proc bMotion_plugin_complex_nazi2 {nick host handle channel text} {
	if [string match "\\" $text] {
		return 0
	}

	if {![bMotion_interbot_me_next $channel]} {
		return 0
	}

	bMotionDoAction $channel $nick "%VAR{nazi2}"
	return 1
}

bMotion_abstract_register "nazi1"
bMotion_abstract_batchadd "nazi1" [list "%%: \"you're\"" "their what?" "s/your/you're/"]

bMotion_abstract_register "nazi2"
bMotion_abstract_batchadd "nazi2" [list "Invalid regular expression." "You suck at the regular expression syntax." "/detects invalid regexp use" "%%: +/" "s/you/suck/"]


