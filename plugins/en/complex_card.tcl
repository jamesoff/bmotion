## bMotion am not!
#
# $Id: complex_fry.tcl 662 2006-01-07 23:27:52Z james $
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

bMotion_plugin_add_complex "card" "^(!card)|(pick a card)" 100 bMotion_plugin_complex_card "en"

proc bMotion_plugin_complex_card {nick host handle channel text} {

	if {[bMotionTalkingToMe $text] || [bMotion_interbot_me_next $channel]} {
		bMotionDoAction $channel $nick "%%: the %VAR{card_value} of %VAR{card_suits}"
		return 1
	}
}

bMotion_abstract_register "card_value" {
	"ace" "two" "three" "four" "five" "six" "seven" "eight" "nine" "jack" "queen" "king"
	"%NUMBER{3000}"
}

bMotion_abstract_register "card_suits" {
	"clubs" "hearts" "spades" "diamonds" "%PLURAL{%VAR{sillyThings}{strip}}"
}
