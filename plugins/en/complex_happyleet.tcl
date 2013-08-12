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

bMotion_plugin_add_complex "happyleet" "happy \[1l\]\[3e\]{2}\[:.-\]?\[t7\]" 100 bMotion_plugin_complex_happyleet "en"

proc bMotion_plugin_complex_happyleet { nick host handle channel text } {

	if {![bMotion_interbot_me_next $channel]} {
		return 0
	}

	set hour [clock format [clock seconds] -format "%H"]
	set minute [clock format [clock seconds] -format "%M"]

	if {$minute != 37} {
		driftFriendship $nick -1
		bMotionDoAction $channel $nick "%VAR{happyleet_fails}"
		return 1
	}

	incr hour 5
	if {$hour > 23} {
		incr hour -24
	}

	if {$hour != 13} {
		set my_hour ""
		if {$hour >= 10} {
			set my_hour "l"
			incr hour -10
			putlog "hour is now $hour"
		}
		switch $hour {
			"0" { append my_hour "o" }
			"1" { append my_hour "l" }
			"2" { append my_hour "z" }
			"3" { append my_hour "e" }
			"4" { append my_hour "a" }
			"5" { append my_hour "s" }
			"6" { append my_hour "g" }
			"7" { append my_hour "t" }
			"8" { append my_hour "b" }
			"9" { append my_hour "g" }
		}
		putlog "happyleet: myhour = $my_hour"

		if {$my_hour == ""} {
			return 0
		}

		bMotionDoAction $channel $nick "happy ${my_hour}et, %%!" 
		driftFriendship $nick -1
		return 1
	}
	driftFriendship $nick 2
}

bMotion_abstract_register "happyleet_fails" {
	"fail"
	"no"
	"wrong"
	"nnk"
	"so close"
}
