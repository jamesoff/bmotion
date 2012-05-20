#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Seward 2000-2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


proc bMotion_plugins_irc_default_join { nick host handle channel text } {
	bMotion_putloglev 4 * "bMotion_plugins_irc_default_join $nick $host $handle $channel $text"

	#if the user isban then dont bother
	if {[ischanban $nick $channel] == 1 } {
		bMotion_putloglev d * "dropping greeting for $nick on $channel as user is banned"
		return 0
	}

	#has something happened since we last greeted?
	set lasttalk [bMotion_plugins_settings_get "system:join" "lasttalk" $channel ""]

	#if 1, we greeted someone last
	#if 0, someone has said something since
	if {$lasttalk == 1} {
		bMotion_putloglev d * "dropping greeting for $nick on $channel because it's too idle"
		return 0
	}

	# skip this check if handle is * as it's pointless
	if {$handle != "*"} {
		# check if the user is already in the channel - probably means they've joined a 2nd client
		# or that they're about to ping out or something
		set count 0
		foreach n [chanlist $channel] {
			if {[nick2hand $n $channel] == $handle} {
			# we have a match
				incr count
			}
		}

		if {$count >= 2} {
			bMotion_putloglev d * "$nick has $count matching handles in $channel, so not greeting"
			return 1
		}
	}

	#we must also see if we're next to greet
	if {![bMotion_interbot_me_next $channel]} {
		bMotion_putloglev 1 * "we're not next for $channel, so not greeting"
		return 1
	}
	
	if {[bMotion_setting_get "friendly"] == "2"} {
		# don't greet anyone
		bMotion_putloglev 1 * "we're friendly==2 so not greeting $nick in $channel"
		return 0
	}

	global botnick 

	set greetings "generic_greeting"
	set lastLeft [bMotion_plugins_settings_get "system:join" "lastleft" $channel ""]

	if {$handle == "*"} {
		if {[bMotion_setting_get "friendly"] != "1"} {
			bMotion_putloglev d * "$nick has no handle and friendly!=1 so not greeting"
			return 0
		}
		set greetings "unknown_joins"
	}

	bMotion_plugins_settings_set "system:join" "lastgreeted" $channel "" $nick
	bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 1

	if {$handle != "*"} {
		if {![rand 10]} {
			set greetings "insult_joins"
			bMotion_putloglev d * "decided to be rude to $nick on join as i know them"
		}
		bMotionGetHappy
		bMotionGetUnLonely
	}

	#set nick [bMotion_cleanNick $nick $handle]
	if {[getFriendship $nick] < 50} {
		set greetings "dislike_joins"
		driftFriendship $nick 1
	}

	if {[getFriendship $nick] > 50} {
		set greetings "friend_greeting"
		driftFriendship $nick -1

		if {$nick == $lastLeft} {
			set greetings "welcomeBacks"
			bMotion_plugins_settings_set "system:join" "lastleft" $channel "" ""
		}
	}

	# generic_greeting = generic greeting
	# friend_greeting = friend greeting
	# dislike_joins = enemy greeting
	# unknown_joins = someone we don't recognise

	bMotion_putloglev 1 * "Selected output for greeeting $nick is $greetings"
	bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{$greetings}"

	return 1
}

bMotion_plugin_add_irc_event "default join" "join" ".*" 40 "bMotion_plugins_irc_default_join" "en"

bMotion_abstract_register "insult_joins" [list "%ruser: yeah, %% does suckOH HI %%!" "\[%%\] I'm a %VAR{PROM}%|%VAR{wrong_infoline}" "\[%%\] I love %ruser%|%VAR{wrong_infoline}" "/looks at %%%|so THAT'S where my oil-skin thong got to!" ]

bMotion_abstract_register "wrong_infoline" [list "oops, wrong infoline, sorry" "huk, wrong infoline" "whoops" "o wait not that infoline"]

bMotion_abstract_register "dislike_joins" [list "shut up" "o no it's %%" "oh no it's %%" "oh noes it's %% %VAR{unsmiles}" "meh" "oh, it's %ruser.%|\"yay\"" "oh, it's fuckmaster mc shitty white clownhorse ass jacket pubic face." "you look beautiful%|incidentally my favourite artist is picasso"]
