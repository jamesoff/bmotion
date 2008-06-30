#
#
# vim: fdm=indent fdn=1 sw=4 ts=4:

###############################################################################
# This is a bMotion plugin
# Copyright (C) Mark Sangster 2006
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "lifts" "(lifts|picks up|hoists) %botnicks" 100 bMotion_plugin_complex_action_lifts "en"

proc bMotion_plugin_complex_action_lifts { nick host handle channel text } {
	global botnicks
	global mood

	bMotion_putloglev d * "bMotion: Got lifted"
	
	if {$mood(happy) < -3} {
		bMotion_putloglev 1 * "bMotion: Don't want lifted!"
		bMotionDoAction $channel $nick "%VAR{nolift_channel_response}"
	} else {
		bMotion_putloglev 1 * "bMotion: Getting lifted yay!"
		bMotionDoAction $channel $nick "%VAR{lift_channel_response}"
	}
	return 1
}

bMotion_abstract_register "nolift_channel_response"
bMotion_abstract_batchadd "nolift_channel_response" {
	"hmmmph :("
	"OI! Don't do that"
	"Stop that right now!"
	"I was happy until %% started pushing me around"
	"%%: stop bothering me"
}

bMotion_abstract_register "lift_channel_response"
bMotion_abstract_batchadd "lift_channel_response" {
	"Weeeeeeeeeeeeeeeeeeeee, do that again!"
	"Ooo aren't we strong"
	"ATTENTION PLEASE: %% is touching my bum!"
	"Weeee!"
}
