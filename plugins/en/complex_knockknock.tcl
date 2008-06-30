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

bMotion_plugin_add_complex "knockknock1" {^knock ?knock[!.?]*} 80 bMotion_plugin_complex_knock1 "en"
bMotion_plugin_add_complex "knockknock2" ".+" 100 bMotion_plugin_complex_knock2 "en"

proc bMotion_plugin_complex_knock1 { nick host handle channel text } {

	#TODO: bMotion_interbot_next
	if (![bMotion_interbot_me_next $channel]) {
		return 0
	}
	
	bMotion_plugins_settings_set "complex:knock" "who" $channel "" $nick
	bMotion_plugins_settings_set "complex:knock" "state" $channel "" 1
	bMotion_plugins_settings_set "complex:knock" "time" $channel "" [clock seconds]
	bMotionDoAction $channel $nick "%VAR{knock1}"
	return 1
}

proc bMotion_plugin_complex_knock2 { nick host handle channel text } {
	set lastnick [bMotion_plugins_settings_get "complex:knock" "who" $channel ""]

	global bMotionOriginalInput
	set text $bMotionOriginalInput

	if {$nick != $lastnick} {
		return 0
	}

	#check if it's 30s since the start
	set now [clock seconds]
	if {$now - [bMotion_plugins_settings_get "complex:knock" "time" $channel ""] > 30} {
		bMotion_plugins_settings_set "complex:knock" "who" $channel "" ""
		return 1
	}

	if {[bMotion_plugins_settings_get "complex:knock" "state" $channel ""] == 1} {
		#next stage: <answer> who?
		bMotion_plugins_settings_set "complex:knock" "state" $channel "" 2
		bMotionDoAction $channel $text "%VAR{knock2}"
		return 1
	}

	if {[bMotion_plugins_settings_get "complex:knock" "state" $channel ""] == 2} {
		#the end
		bMotion_plugins_settings_set "complex:knock" "state" $channel "" 0
		bMotion_plugins_settings_set "complex:knock" "who" $channel "" ""
		bMotionDoAction $channel $nick "%VAR{knock3}"
		return 1
	}
}
bMotion_abstract_register "knock1"
bMotion_abstract_batchadd "knock1" [list "%%: Who's there?" "who's there?"]

bMotion_abstract_register "knock2"
bMotion_abstract_batchadd "knock2" [list "%% who?"]

bMotion_abstract_register "knock3"
bMotion_abstract_batchadd "knock3" [list "%REPEAT{3:10:ha}" "%REPEAT{3:10:ha}%|I don't get it." "..." "?" "lol" "what" "%VAR{smiles}"]

