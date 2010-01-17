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

bMotion_plugin_add_complex "hello" "^(hey|hi|hello|r|greetings|hullo|bonjour|morning|afternoon|evening|yo|y0|lo|morn|moin) (all|%botnicks)(!)?$" 100 bMotion_plugin_complex_hello "en"
bMotion_plugin_add_complex "hello2" "^%botnicks(!+|\[!\"£\$%^&*()#\]{3,})" 100 bMotion_plugin_complex_hello "en"

proc bMotion_plugin_complex_hello { nick host handle channel text } {
	global botnicks
	set exclaim ""
	regexp -nocase "^${botnicks}(!+|\[!\"£\$%^&*()#\]{3,})" $text bling pop exclaim
	global bMotionInfo 

	set lastGreeted [bMotion_plugins_settings_get "complex:hello" "lastGreeted" $channel ""]

	if {$bMotionInfo(away) == 1} {
		putserv "AWAY"
		set bMotionInfo(away) 0
		set bMotionInfo(silence) 0
		bMotionDoAction $channel "" "/returns"
	}

	driftFriendship $handle 3

	#check if this nick has already been greeted
	if {$lastGreeted == $handle} {
		bMotionDoAction $channel "" "%VAR{smiles}"
		return 1
	}

	bMotion_plugins_settings_set "complex:hello" "lastGreeted" $channel "" $handle

	if {[string length $exclaim] >= 3} {
		set greeting "%%%colen"
	} else {
		if {[getFriendship $nick] > 60} {
			set greeting "%VAR{hello_familiars}"
		} else {
			set greeting "%VAR{greetings}"
		}
	}

	# get random nick from realnames
	set nick [bMotionGetRealName $nick]

	bMotionDoAction $channel $nick $greeting
	return 1
}

bMotion_abstract_register "hello_familiars"
bMotion_abstract_batchadd "hello_familiars" {
	"%%%colen"
	"%%!"
	"%% :D"
	"%% ^_^"
	"/hugs %%"
	"r %VAR{smiles}"
}
