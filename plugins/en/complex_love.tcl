## bMotion Module: love
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

bMotion_plugin_add_complex "love" "i (love|luv|wov|wuv|luvly|lovely) (you,? %botnicks|%botnicks)" 100 bMotion_plugin_complex_love "en"
bMotion_plugin_add_complex "love2" "i think (you are|you're) (wuvly|luvly|lovely),? %botnicks" 100 bMotion_plugin_complex_love "en"
bMotion_plugin_add_complex "love3" "i think %botnicks is (wuvly|luvly|lovely)" 100 bMotion_plugin_complex_love "en"

proc bMotion_plugin_complex_love { nick host handle channel text } {

	# people we don't like can be told where to shove it
	# but we'll let them get a bit of friendship as a result
	if {![bMotionIsFriend $nick]} {
		bMotionDoAction $channel $nick "%VAR{love_failed}"
		driftFriendship $nick 4
		return 1
	}

	driftFriendship $nick 8
	# people of the wrong gender get the platonic treatment
	if {![bMotionLike $nick $host]} {
		bMotionDoAction $channel $nick "%VAR{love_like}"
		return 1
	}

	if {[bMotion_mood_get happy] < 15 && [bMotion_mood_get lonely] < 5} {
		bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{loveresponses}"
		bMotionGetHappy
		bMotionGetUnLonely
		bMotion_plugins_settings_set "system" "lastdonefor" $channel "" $nick
		return 1
	} else {
		bMotionDoAction $channel "" "hehe, want to go out on a date someplace? %SMILEY{smile}"
		bMotion_mood_adjust happy -10
		bMotion_plugins_settings_set "system" "lastdonefor" $channel "" $nick
		return 1
	}
}

bMotion_abstract_register "love_like" {
	"i love you %%, as a friend"
	"ok"
	"/<3 %% as a friend"
	"%VAR{smiles}"
}

bMotion_abstract_register "love_failed" {
	"get away from me"
	"/pushes %% away"
	"shame, because i think you're a smelly %VAR{bodypart}"
	"go away"
	"shove off you %VAR{PROM}"
}

