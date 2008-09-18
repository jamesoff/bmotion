# bMotion: admin plugin file for plugin mangement
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

#register the plugin
bMotion_plugin_add_management "plugin" "^plugin" n "bMotion_plugin_management_plugins" "any"

proc bMotion_plugin_management_plugins { handle { arg "" }} {
	#plugin remove <type> <id>
	if [regexp -nocase {remove ([^ ]+) (.+)} $arg matches t id] {
		bMotion_putadmin "Removing $t plugin $id..."
		set full_array_name_for_upvar "bMotion_plugins_$t"
		upvar #0 $full_array_name_for_upvar TEH_ARRAY
		unset TEH_ARRAY($id)
		bMotion_putadmin "...done."
		return 0
	}

	#enable a plugin
	set channel ""
	if [regexp -nocase {enable ([^ ]+) (.+?)( .+)?} $arg matches t id channel] {
		if {$t == "output"} {
			if {$channel != ""} {
				set channel [string trim $channel]
				bMotion_putadmin "Enabling output plugin $id on channel $channel..."
				if [bMotion_plugin_set_output_channel $id $channel 1] {
					bMotion_putadmin "...done."
				}
				return 0 
			} else {
				bMotion_putadmin "Enabling output plugin $id globally..."
				if [bMotion_plugin_set_output $id 1] {
					bMotion_putadmin "...done."
				}
				return 0
			}
		}

		#invalid plugin to enable
		bMotion_putadmin "That's not a valid plugin type for enabling."
	}

	#disable a plugin
	if [regexp -nocase {disable ([^ ]+) (.+?)( .+)?} $arg matches t id channel] {
		if {$t == "output"} {
			bMotion_putadmin "Disabling output plugin $id..."
			if {$channel != ""} {
				set channel [string trim $channel]
				bMotion_putadmin "Disabling output plugin $id on channel $channel..."
				if [bMotion_plugin_set_output_channel $id $channel 0] {
					bMotion_putadmin "...done."
				}
				return 0 
			} else {
				bMotion_putadmin "Disable output plugin $id globally..."
				if [bMotion_plugin_set_output $id 0] {
					bMotion_putadmin "...done."
				}
				return 0
			}
		}

		#invalid plugin to enable
		bMotion_putadmin "That's not a valid plugin type for disabling."
	}

	if [regexp -nocase {info ([^ ]+) (.+)} $arg matches t id] {
		global bMotion_plugins_output_perchan

		set full_array_name_for_upvar "bMotion_plugins_$t"
		upvar #0 $full_array_name_for_upvar TEH_ARRAY

		set details $TEH_ARRAY($id)

		switch $t {
			"simple" -
			"action_simple" {
				global BMOTION_PLUGIN_SIMPLE_MATCH BMOTION_PLUGIN_SIMPLE_CHANCE BMOTION_PLUGIN_SIMPLE_RESPONSE BMOTION_PLUGIN_SIMPLE_LANGUAGE
				bMotion_putadmin "Plugin details for ${t}:$id ([lindex $details $BMOTION_PLUGIN_SIMPLE_LANGUAGE]) [lindex $details $BMOTION_PLUGIN_SIMPLE_CHANCE]%"
				bMotion_putadmin "  Match on: [lindex $details $BMOTION_PLUGIN_SIMPLE_MATCH]"
				bMotion_putadmin "  Response list: [lindex $details $BMOTION_PLUGIN_SIMPLE_RESPONSE]"
				return 0
			}
			"complex" -
			"action_complex" {
				global BMOTION_PLUGIN_COMPLEX_MATCH BMOTION_PLUGIN_COMPLEX_CHANCE BMOTION_PLUGIN_COMPLEX_CALLBACK BMOTION_PLUGIN_COMPLEX_LANGUAGE
				bMotion_putadmin "Plugin details for ${t}:$id ([lindex $details $BMOTION_PLUGIN_COMPLEX_LANGUAGE]) [lindex $details $BMOTION_PLUGIN_COMPLEX_CHANCE]%"
				bMotion_putadmin "  Match on: [lindex $details $BMOTION_PLUGIN_COMPLEX_MATCH]"
				bMotion_putadmin "  Callback: [lindex $details $BMOTION_PLUGIN_COMPLEX_CALLBACK]"
				return 0
			}
			"output" {
				global BMOTION_PLUGIN_OUTPUT_PRIORITY BMOTION_PLUGIN_OUTPUT_ENABLED BMOTION_PLUGIN_OUTPUT_LANGUAGE BMOTION_PLUGIN_OUTPUT_CALLBACK
				bMotion_putadmin "Plugin details for output:$id ([lindex $details $BMOTION_PLUGIN_OUTPUT_LANGUAGE]) Priority:[lindex $details $BMOTION_PLUGIN_OUTPUT_PRIORITY]"
				if {[lindex $details $BMOTION_PLUGIN_OUTPUT_ENABLED] == 1} {
					bMotion_putadmin "  Enabled on: all channels"
				} else {
					set current [list]
					catch {
						set current $bMotion_plugins_output_perchan($id)
					}
					if {[llength $current] > 0} {
						bMotion_putadmin "  Enabled on channels: $current"
					} else {
						bMotion_putadmin "  Enabled: no"
					}
				}
				bMotion_putadmin "  Callback: [lindex $details $BMOTION_PLUGIN_OUTPUT_CALLBACK]"
				return 0
			}
			"event" -
			"irc_event" {
				global BMOTION_PLUGIN_EVENT_TYPE BMOTION_PLUGIN_EVENT_MATCH BMOTION_PLUGIN_EVENT_CHANCE BMOTION_PLUGIN_EVENT_CALLBACK BMOTION_PLUGIN_EVENT_LANGUAGE
				bMotion_putadmin "Plugin details for irc_event:$id ([lindex $details $BMOTION_PLUGIN_EVENT_LANGUAGE]) [lindex $details $BMOTION_PLUGIN_EVENT_CHANCE]%"
				bMotion_putadmin "  Event type: [lindex $details $BMOTION_PLUGIN_EVENT_TYPE], match on: [lindex $details $BMOTION_PLUGIN_EVENT_MATCH]"
				bMotion_putadmin "  Callback: [lindex $details $BMOTION_PLUGIN_EVENT_CALLBACK]"
				return 0
			}
			"management" {
				global BMOTION_PLUGIN_MANAGEMENT_MATCH BMOTION_PLUGIN_MANAGEMENT_FLAGS BMOTION_PLUGIN_MANAGEMENT_CALLBACK BMOTION_PLUGIN_MANAGEMENT_HELPCALLBACK
				bMotion_putadmin "Plugin details for management:$id ([lindex $details $BMOTION_PLUGIN_MANAGEMENT_FLAGS])"
				bMotion_putadmin "  Match: [lindex $details $BMOTION_PLUGIN_MANAGEMENT_MATCH]"
				bMotion_putadmin "  Callback: [lindex $details $BMOTION_PLUGIN_MANAGEMENT_CALLBACK]"
				bMotion_putadmin "  Help callback: [lindex $details $BMOTION_PLUGIN_MANAGEMENT_HELPCALLBACK]"
				return 0
			}
			default {
				bMotion_putadmin "?"
				return 0
			}
		}
	}

	#all else fails, list the modules:
	if [regexp -nocase {list( (.+))?} $arg matches what re] {
		global BMOTION_PLUGIN_OUTPUT_ENABLED BMOTION_PLUGIN_OUTPUT_PRIORITY

		set total 0
		if {$re != ""} {
			bMotion_putadmin "Installed bMotion plugins (filtered for '$re'):"
		} else {
			bMotion_putadmin "Installed bMotion plugins:"
		}
		foreach t {simple complex output action_simple action_complex irc_event management} {
			set arrayName "bMotion_plugins_$t"
			upvar #0 $arrayName plugins
			set plugin_names [lsort [array names plugins]]
			set a "\002$t\002: "
			set count 0
			foreach n $plugin_names {
				if {($re == "") || [regexp -nocase $re $n]} {
					if {[string length $a] > 55} {
						bMotion_putadmin "$a"
						set a "			"
					}
					incr count
					incr total
					if {$t == "output"} {
						set details $plugins($n)
						append a [lindex $plugins($n) $BMOTION_PLUGIN_OUTPUT_PRIORITY]
						if {[lindex $plugins($n) $BMOTION_PLUGIN_OUTPUT_ENABLED] == 1} {
							append a "/$n\[on\], "
						} else {
							append a "/$n\[off\], "
						}
					} else {
						append a "$n, "
					}
				}
			}
			regsub ", *\$" $a "" a
			if {($re != "") && $count} {
				bMotion_putadmin "$a ($count)\n"
			} else {
				bMotion_putadmin $a
			}
		}
		bMotion_putadmin "Total plugins: $total"
		return 0
	}

	#all else fails, give usage:
	bMotion_putadmin "usage: plugins (list|info|remove|enable|disable)"
	return 0
}
