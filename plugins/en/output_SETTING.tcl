#
#
# vim: fdm=indent fdn=1
#
 
###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, %SETTING

proc bMotion_plugin_output_SETTING { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_SETTING $channel $line"

	set lastline ""

	while {[regexp "%SETTING\{(.+?)\}" $line matches settingString]} {
		set var ""
		if [regexp {([^:]+:[^:]+):([^:]+):([^:]+):([^:]+)} $settingString matches plugin setting ch ni] {
			set var [bMotion_plugins_settings_get $plugin $setting $ch $ni]
		}
		if {$var == ""} {
			putlog "bMotion: ALERT! couldn't find setting $settingString (dropping output)"
			return ""
		}
		set line [bMotionInsertString $line "%SETTING{$settingString}" $var]

		if {$lastline == $line} {
			putlog "bMotion: ALERT: couldn't parse $line for %SETTING (dropping output)"	
			set line ""
			break
		}
	}

	return $line
}

bMotion_plugin_add_output "SETTING" bMotion_plugin_output_SETTING 1 "en" 5
