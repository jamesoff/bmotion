## bMotion yes, you did
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

bMotion_plugin_add_complex "yesyoudid" "^(yes|no),? \[a-z\]+ \[a-z'\]+\[!.\]?$" 100 bMotion_plugin_complex_yesyoudid "en"

proc bMotion_plugin_complex_yesyoudid {nick host handle channel text} {
	if [regexp -nocase "^(yes|no),? (\[a-z\]+) (\[a-z'\]+)\[!.\]?$" $text matches yesno you did] {
		set lastyesno [bMotion_plugins_settings_get "complex:yesyoudid" "yesno" $channel ""]
		set lastyou [bMotion_plugins_settings_get "complex:yesyoudid" "you" $channel ""]
		set lastdid [bMotion_plugins_settings_get "complex:yesyoudid" "did" $channel ""]
		set lasttime [bMotion_plugins_settings_get "complex:yesyoudid" "time" $channel ""]
		set count [bMotion_plugins_settings_get "complex:yesyoudid" "count" $channel ""]
		set wedid [bMotion_plugins_settings_get "complex:yesyoudid" "wedid" $channel ""]

		if {[string match -nocase $lastyesno $yesno] && [string match -nocase $lastyou $you] && [string match -nocase $lastdid $did]} {
			bMotion_putloglev d * "yesyoudid: matched a combo"


			#if the first time we saw this combo is more than 120 seconds ago, we reset our participation
			set diff [expr [clock seconds] - $lasttime]
			bMotion_putloglev d * "yesyoudid: this combo started $diff seconds ago"
			if {$diff > 120} {
				set wedid 0
				set count 0
			}

			if {$wedid} {
				# we already answered this one
				bMotion_putloglev d * "yesyoudid: we already answered this one"
				return 0
			}

			# we need to see it twice before we'll join in
			incr count
			bMotion_plugins_settings_set "complex:yesyoudid" "count" $channel "" $count
			bMotion_putloglev d * "yesyoudid: seen this combo $count times"
			if {$count < 3} {
				bMotion_putloglev d * "yesyoudid: that's not enough times yet"
				return 0
			}

			# TODO: interbot? not sure
			if {[rand 100] > 40} {
				bMotion_putloglev d * "yesyoudid: we did too"
				bMotionDoAction $channel $yesno "%VAR{yesyoudids}" "$you $did"
				bMotion_plugins_settings_set "complex:yesyoudid" "wedid" $channel "" 1
				return 1
			}
			return 0
		} else {
			# a new one!
			bMotion_plugins_settings_set "complex:yesyoudid" "yesno" $channel "" $yesno
			bMotion_plugins_settings_set "complex:yesyoudid" "you" $channel "" $you
			bMotion_plugins_settings_set "complex:yesyoudid" "did" $channel "" $did
			bMotion_plugins_settings_set "complex:yesyoudid" "time" $channel "" [clock seconds]
			bMotion_plugins_settings_set "complex:yesyoudid" "wedid" $channel "" 0
			bMotion_plugins_settings_set "complex:yesyoudid" "count" $channel "" 1
			bMotion_putloglev d * "yesyoudid: learned a new sequence, yesno=$yesno, you=$you, did=$did, channel=$channel"
			return 0
		}
	}
}

bMotion_abstract_register "yesyoudids" {
	"%%, %2"
	"%% %2"
}
