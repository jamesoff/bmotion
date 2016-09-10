## bMotion plugins loader: output
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

set languages [split $bMotionSettings(languages) ","]
foreach bMotion_language $languages {
	bMotion_log "plugins" "INFO" "loading output plugins language = $bMotion_language"
	set files [glob -nocomplain "$bMotionPlugins/$bMotion_language/output_*.tcl"]
	foreach f $files {
		set count [llength [array names bMotion_plugins_output]]
		bMotion_log "plugins" "DEBUG" "bMotion: loading ($bMotion_language) output plugin file $f"
		set bMotion_noplugins 0
		catch {
			source $f
		} err
		set newcount [llength [array names bMotion_plugins_output]]
		if {($bMotion_testing == 0) && ($newcount == $count) && ($bMotion_noplugins == 0)} {
			bMotion_log "plugins" "WARN" "ALERT! output plugin file $f added no plugins"
			bMotion_log "plugins" "WARN" "Possible error: $err"
		}
	}
}

# enable or disable plugins as per the settings file
# setting format:
# pluginname1:1,pluginname2=#channel,pluginname3:0
# enables pluginname1 globally, pluginname2 on #channel, and disables pluginname3

set output_preenables [split [bMotion_setting_get "output_preenables"] ","]

foreach output_preenable $output_preenables {
	if {[string range $output_preenable end-1 end] == ":1"} {
		set plugin [string range $output_preenable 0 [expr [string last ":1" $output_preenable] - 1]]
		bMotion_log "plugins" "INFO" "Globally enabling output plugin $plugin from settings file"
		bMotion_plugin_set_output $plugin 1
		continue
	}

	if {[string range $output_preenable end-1 end] == ":0"} {
		set plugin [string range $output_preenable 0 [expr [string last ":1" $output_preenable] - 1]]
		bMotion_log "plugins" "INFO" "Globally disabling output plugin $plugin from settings file"
		bMotion_plugin_set_output $plugin 0
		continue
	}

	if [string match "*=*" $output_preenable] {
		set plugin [string range $output_preenable 0 [expr [string last "=" $output_preenable] - 1]]
		set chan [string range $output_preenable [expr [string last "=" $output_preenable] + 1] end]
		bMotion_log "plugins" "INFO" "Enabling output plugin $plugin on channel $chan from settings file"
		bMotion_plugin_set_output_channel $plugin $chan 1
		continue
	}

	bMotion_log "plugins" "ERROR" "error parsing output_preenables: not sure what to do with $output_preenable"
}

