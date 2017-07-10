#
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

#                          name   regexp               chance  callback
bMotion_plugin_add_complex "swisstoni" {[a-z]+ing (an?|the|some) [a-z]+} 10 "bMotion_plugin_complex_swisstoni" "en"

proc bMotion_plugin_complex_swisstoni { nick host handle channel text } {
	if {[regexp {([a-z]+ing) (an?|the|some) ([a-z]+)\M} $text matches verb middle noun]} {
		set last_time [bMotion_plugins_settings_get "complex:swisstoni" "last" $channel ""]
		if {$last_time == ""} {
			set last_time 0
		}
		set now [clock seconds]
		set diff [expr $now - $last_time]

		if {$diff > [expr [rand 10000] + 40000]} {
			bMotion_plugins_settings_set "complex:swisstoni" "last" $channel "" $now
			if {[string tolower $verb] == "during"} {
				# happy to burn a "use" without replying as this plugin can fire quite frequently anyway
				return 0
			}
			bMotionDoAction $channel $nick "You know %%, $verb $middle $noun is much like making love to a beautiful woman%|You've got to %VAR{sillyVerbs} the %VAR{sillyThings:strip}%|%VAR{sillyVerbs} the %VAR{sillyThings:strip}%|and finally %VAR{sillyVerbs} the %VAR{sillyThings:strip}."
			return 1
		}
	}
}

