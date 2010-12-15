#
#
# vim: fdm=indent fdn=1 sw=4 ts=4:

###############################################################################
# This is a bMotion plugin
# Copyright (C) James "Off" Seward 2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "cracker" "pulls an? ((christ|x)mas )?cracker with %botnicks" 100 bMotion_plugin_complex_action_cracker "en"

proc bMotion_plugin_complex_action_cracker { nick host handle channel text } {
	global botnicks

	# don't do this outside of dec
	set month [clock format [clock seconds] -format "%m"]
	if {$month != "12"} {
		return
	}

	bMotionDoAction $channel $nick "%VAR{cracker_boom}"

	if [rand 2] {
		# i won
		bMotionDoAction $channel $nick "%VAR{cracker_win}"
		if [rand 2] {
			bMotionDoAction $channel $nick "%VAR{cracker_win_hat}"
		}
		return 1
	} else {
		# $nick won
		bMotionDoAction $channel $nick "%VAR{cracker_lose}"
		if [rand 2] {
			bMotionDoAction $channel $nick "%VAR{cracker_lose_hat}"
		}
		return 1
	}

}
bMotion_abstract_register "cracker_boom" {
	"%VAR{booms}"
	"%VAR{sfx} %VAR{surprises}"
}

bMotion_abstract_register "cracker_win" {
	"%VAR{yays}! i won!%|/got %VAR{cracker_want_item} %VAR{smiles}"
	"%VAR{yays}! i won!%|/got %VAR{cracker_nowant_item}. hmm %VAR{unsmiles}"
	"%VAR{yays}! i won!%|i got %VAR{cracker_want_item} %VAR{smiles}"
	"%VAR{yays}! i won!%|oh, i got %VAR{cracker_nowant_item} %VAR{unsmiles}"
	"%VAR{yays}! i won %VAR{cracker_nowant_item}... but I'd rather have had a %VAR{_bmotion_like}"
	"%VAR{yays}! i won %VAR{cracker_want_item}%|glad I didn't get a %VAR{_bmotion_dislike}, i hate those"
}

bMotion_abstract_register "cracker_lose" {
	"%VAR{boos} i didn't win%|%VAR{yays}! you got %VAR{cracker_neutral_item}"
	"%VAR{boos} i didn't win%|%VAR{yays}! you got %VAR{cracker_want_item} *jealous*"
	"%VAR{boos} i didn't win%|%VAR{yays}! you got a %VAR{cracker_want_item} %VAR{unsmiles} wish i'd got that"
	"%VAR{boos} i didn't win%|oh you got a %VAR{cracker_nowant_item} %VAR{smiles} glad i didn't get that!"
	"%VAR{boos} you won%|%VAR{cracker_want_item}! nice!"
}

bMotion_abstract_register "cracker_win_hat" {
	"/puts on hat"
	"*hat*"
	"*puts on hat*"
}

bMotion_abstract_register "cracker_lose_hat" {
	"don't forget to put on your hat"
	"here's your hat!"
	"put on your hat!"
}

bMotion_abstract_register "cracker_want_item" {
	"%VAR{sillyThings:like}"
	"a %VAR{scrap_adult_adjectives_t} %VAR{scrap_adult_construction_t:strip}"
	"a %VAR{scrap_silly_qualities} %VAR{scrap_silly_adjectives} %VAR{scrap_silly_construction}"
}

bMotion_abstract_register "cracker_neutral_item" {
	"%VAR{sillyThings}"
	"a %VAR{scrap_adult_adjectives_t} %VAR{scrap_adult_construction_t:strip}"
	"a %VAR{scrap_silly_qualities} %VAR{scrap_silly_adjectives} %VAR{scrap_silly_construction}"
}

bMotion_abstract_register "cracker_nowant_item" {
	"%VAR{sillyThings:dislike}"
	"a %VAR{scrap_adult_adjectives_t} %VAR{scrap_adult_construction_t:strip}"
	"a %VAR{scrap_silly_qualities} %VAR{scrap_silly_adjectives} %VAR{scrap_silly_construction}"
}
