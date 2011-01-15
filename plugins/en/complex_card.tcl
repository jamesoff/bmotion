## bMotion am not!
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

bMotion_plugin_add_complex "card" "^(!card( (adult))?)|(pick a card)" 100 bMotion_plugin_complex_card "en"

proc bMotion_plugin_complex_card {nick host handle channel text} {
	if {[bMotionTalkingToMe $text] || [bMotion_interbot_me_next $channel]} {
		set modifier ""
		regexp -nocase "^!card( (adult))?" $text matches 1 modifier
		if {[string tolower $modifier] == "adult"} {
			bMotionDoAction $channel $nick "%%: the %VAR{card_value} of %VAR{scrap_adult_adjectives_t} %VAR{scrap_adult_construction_t:strip,plural}"
			return 1
		}

		bMotionDoAction $channel $nick "%%: the %VAR{card_value} of %VAR{card_suits}"
		return 1
	}
}

bMotion_abstract_register "card_value" {
	"ace" "two" "three" "four" "five" "six" "seven" "eight" "nine" "jack" "queen" "king"
	"%NUMBER{3000}"
}

bMotion_abstract_register "card_suits" {
	"clubs" "hearts" "spades" "diamonds" "%VAR{sillyThings:strip,plural}"
}

bMotion_abstract_add_filter "card_suits" "%PLURAL"

