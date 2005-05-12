## bMotion plugin: knock knock
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "knockknock1" {^knock ?knock[!.?]*} 50 bMotion_plugin_complex_knock1 "en"
bMotion_plugin_add_complex "knockknock2" ".+" 100 bMotion_plugin_complex_knock2 "en"

proc bMotion_plugin_complex_knock1 { nick host handle channel text } {

	#TODO: bMotion_interbot_next
	
	bMotion_plugin_settings_set "complex:knock" "who" $channel "" $nick
	bMotion_plugin_settings_set "complex:knock" "state" $channel "" 1
	bMotionDoAction $channel $nick "%VAR{knock1}"
	return 1
}

proc bMotion_plugin_complex_knock2 { nick host handle channel text } {
	set lastnick [bMotion_plugin_settings_get "complex:knock" "who" $channel ""]

	if {$nick != $lastnick} {
		bMotion_plugin_settings_set "complex:knock" "who" $channel "" ""
		return 0
	}

	if {[bMotion_plugin_settings_get "complex:knock" "state" $channel ""] == 1} {
		#next stage: <answer> who?
		bMotion_plugin_settings_set "complex:knock" "state" $channel "" 2
		bMotionDoAction $channel $text "%VAR{knock2}"
		return 1
	}

	if {[bMotion_plugin_settings_get "complex:knock" "state" $channel ""] == 2} {
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

