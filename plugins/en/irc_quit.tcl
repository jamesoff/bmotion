#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_plugins_irc_default_quit { nick host handle channel text } {

	if {[bMotion_setting_get "friendly"] == "2"} {
		bMotion_putloglev 2 * "skipping quit for $nick due to friendly == 2"
		return 0
	}

	if {$handle == "*"} {
		if {[bMotion_setting_get "friendly"] != 1} {
			bMotion_putloglev 2 * "skipping quit for $nick because handle is * and friendly != 1"
			return 0
		}
	}

	# check if the handle is still in the channel
	set count 0
	foreach n [chanlist $channel] {
		if {[nick2hand $n $channel] == $handle} {
			# we have a match
			incr count
		}
	}

	# note: this is 2 not 1 because this event is fired BEFORE eggdrop processes the part/quit
	if {$count >= 2} {
		bMotion_putloglev d * "$nick has $count matching handles in $channel, so not saying bye"
		return 0
	}

	#don't do anything if it looks like an error
	if [regexp -nocase "(k-?lined|d-?lined|ircd?\.|error|reset|timeout|closed|peer|\.net|timed|eof|lost)" $text] {
		bMotion_putloglev d * "Looks like $nick quit due to error"
		bMotion_redis_cmd set quits:$nick:waserror 1 ex 1800
		return 0
	}

	bMotion_redis_cmd set quits:$nick:waserror 0 ex 1800

	if {[bMotionIsFriend $nick]} {
		set output "%VAR{departs-nice}"
	} else {
		set output "%VAR{departs-nasty}"
	}
	
	#has something happened since we last spoke?
	set lasttalk [bMotion_plugins_settings_get "system:join" "lasttalk" $channel ""]

	#if 1, we greeted someone last
	#if 0, someone has said something since
	if {$lasttalk == 1} {
		bMotion_putloglev d * "dropping depart for $nick on $channel because it's too idle"
		return 0
	}

	# now we want to work out if we should fire (15% of the time)
	# everything above must trigger at 100% for us to keep track of things
	
	if {[rand 100] < 15} {
		bMotion_putloglev 2 * "sending quit message for $nick to $channel"
		bMotionDoAction $channel [bMotionGetRealName $nick $host] $output
		bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 1
		bMotion_plugins_settings_set "system:join" "lastleft" $channel "" $nick
		bMotion_plugins_settings_set "system:join" "lastgreeted" $channel "" $nick
		return 1
	} else {
		return 0
	}
}

bMotion_plugin_add_irc_event "default quit" "quit" ".*" 100 "bMotion_plugins_irc_default_quit" "en"
bMotion_plugin_add_irc_event "default part" "part" ".*" 100 "bMotion_plugins_irc_default_quit" "en"

bMotion_abstract_register "departs-nice" [list "bye %%" "i like them %VAR{smiles}" "i wish they didn't have to go %VAR{unsmiles}" "mmm %%"]

bMotion_abstract_register "departs-nasty" [list "bye sucker" "i don't like them" "i hope they don't come back" "%%: AND DON'T COME BACK!" "See You Next Tuesday, %%!" "%%: don't let the door hit your ass on the way out%|because I don't want ass-prints on my new door!" "what a %VAR{insults} %VAR{unsmiles}"]

