## plugins engine for bMotion
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2008
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

bMotion_log_add_category "plugins"

# "Constants"
set BMOTION_PLUGIN_SIMPLE_MATCH 0
set BMOTION_PLUGIN_SIMPLE_CHANCE 1
set BMOTION_PLUGIN_SIMPLE_RESPONSE 2
set BMOTION_PLUGIN_SIMPLE_LANGUAGE 3
set BMOTION_PLUGIN_SIMPLE_COMPILED 4

set BMOTION_PLUGIN_MANAGEMENT_MATCH 0
set BMOTION_PLUGIN_MANAGEMENT_FLAGS 1
set BMOTION_PLUGIN_MANAGEMENT_CALLBACK 2
set BMOTION_PLUGIN_MANAGEMENT_HELPCALLBACK 3

set BMOTION_PLUGIN_COMPLEX_MATCH 0
set BMOTION_PLUGIN_COMPLEX_CHANCE 1
set BMOTION_PLUGIN_COMPLEX_CALLBACK 2
set BMOTION_PLUGIN_COMPLEX_LANGUAGE 3
set BMOTION_PLUGIN_COMPLEX_COMPILED 4

set BMOTION_PLUGIN_OUTPUT_CALLBACK 0
set BMOTION_PLUGIN_OUTPUT_ENABLED 1
set BMOTION_PLUGIN_OUTPUT_LANGUAGE 2
set BMOTION_PLUGIN_OUTPUT_PRIORITY 3

set BMOTION_PLUGIN_EVENT_TYPE 0
set BMOTION_PLUGIN_EVENT_MATCH 1
set BMOTION_PLUGIN_EVENT_CHANCE 2
set BMOTION_PLUGIN_EVENT_CALLBACK 3
set BMOTION_PLUGIN_EVENT_LANGUAGE 4

## Simple plugins
if [info exists bMotion_plugins_simple] { unset bMotion_plugins_simple }
array set bMotion_plugins_simple {}

## Admin plugins (.bmotion)
if [info exists bMotion_plugins_admin] { unset bMotion_plugins_admin }
array set bMotion_plugins_admin {}

## complex plugins
if [info exists bMotion_plugins_complex] { unset bMotion_plugins_complex }
array set bMotion_plugins_complex {}

## output plugins
if [info exists bMotion_plugins_output] { unset bMotion_plugins_output }
array set bMotion_plugins_output {}

## action simple plugins
if [info exists bMotion_plugins_action_simple] { unset bMotion_plugins_action_simple }
array set bMotion_plugins_action_simple {}

## action complex plugins
if [info exists bMotion_plugins_action_complex] { unset bMotion_plugins_action_complex }
array set bMotion_plugins_action_complex {}

## irc_event plugins
if [info exists bMotion_plugins_irc_event] { unset bMotion_plugins_irc_event }
array set bMotion_plugins_irc_event {}

## management plugins
if [info exists bMotion_plugins_management] { unset bMotion_plugins_management }
array set bMotion_plugins_management {}

#
# Load a simple plugin
proc bMotion_plugin_add_simple { id match chance response language} {
	global bMotion_plugins_simple plugins bMotion_testing bMotion_noplugins bMotionCache
	global BMOTION_PLUGIN_SIMPLE_MATCH BMOTION_PLUGIN_SIMPLE_CHANCE BMOTION_PLUGIN_SIMPLE_RESPONSE BMOTION_PLUGIN_SIMPLE_LANGUAGE BMOTION_PLUGIN_SIMPLE_COMPILED

	if {$bMotion_testing == 0} {
		catch {
			set test $bMotion_plugins_simple($id)
			bMotion_log "plugins" "WARN" "bMotion: ALERT! Simple plugin $id is defined more than once"
			return 0
		}
	}
	if [bMotion_plugin_check_allowed "simple:$id"] {
		set bMotion_plugins_simple($id) [list $match $chance $response $language ""]
		bMotion_log "plugins" "DEBUG" "bMotion: added simple plugin: $id"
		append plugins "$id,"
		set bMotionCache(compiled) 0
		return 1
	}
	bMotion_log "plugins" "INFO" "bMotion: ignoring disallowed plugin simple:$id"
	set bMotion_noplugins 1
}


## Find a simple plugin
proc bMotion_plugin_find_simple { text lang { debug 0 }} {

	bMotion_log "plugins" "TRACE" "bMotion_plugin_find_simple: text = $text, lang = $lang"
	global bMotion_plugins_simple botnicks
	global BMOTION_PLUGIN_SIMPLE_MATCH BMOTION_PLUGIN_SIMPLE_CHANCE BMOTION_PLUGIN_SIMPLE_RESPONSE BMOTION_PLUGIN_SIMPLE_LANGUAGE BMOTION_PLUGIN_SIMPLE_COMPILED

	set s [lsort [array names bMotion_plugins_simple]]

	bMotion_compile_matches

	foreach key $s {
		set val $bMotion_plugins_simple($key)
		set rexp [lindex $val $BMOTION_PLUGIN_SIMPLE_COMPILED]
		set chance [lindex $val $BMOTION_PLUGIN_SIMPLE_CHANCE]
		set response [lindex $val $BMOTION_PLUGIN_SIMPLE_RESPONSE]
		set language [lindex $val $BMOTION_PLUGIN_SIMPLE_LANGUAGE]

		if {[string match $lang $language] || ($language == "any")} {
			if [regexp -nocase $rexp $text] {
				set c [rand 100]
				if {$debug} {
					set c 0
				}
				bMotion_log "plugins" "TRACE" "simple plugin $key matches"
				if {[bMotion_plugins_settings_get "system" "last_simple" "" ""] == $key} {
					bMotion_log "plugins" "WARN" "trying to trigger same simple plugin twice in a row, aborting"
					return ""
				}
				bMotion_plugins_settings_set "system" "last_simple" "" "" $key
				if {$chance > $c} {
					bMotion_log "plugins" "DEBUG" "firing simple plugin $key"
					return $response
				}
			}
		}
	}
	return ""
}


## Load management plugin: TODO: Still generating dups?
proc bMotion_plugin_add_management { id match flags callback { language "" } { helpcallback "" } } {
	global bMotion_plugins_management plugins bMotion_testing bMotion_noplugins

	if {$bMotion_testing == 0} {
		catch {
			set test $bMotion_plugins_management($id)
			bMotion_log "plugins" "WARN" "ALERT! management plugin $id is defined more than once ($bMotion_testing)"
			return 0
		}
		if [bMotion_plugin_check_allowed "management:$id"] {
			set bMotion_plugins_management($id) [list $match $flags $callback $helpcallback]
			bMotion_log "plugins" "DEBUG" "bMotion: added management plugin: $id"
			append plugins "$id,"
			return 1
		}
		bMotion_log "plugins" "INFO" "bMotion: ignoring disallowed plugin management:$id"
		set bMotion_noplugins 1
	}
}

## Find management plugin
proc bMotion_plugin_find_management { text } {
	global bMotion_plugins_management
	global BMOTION_PLUGIN_MANAGEMENT_MATCH BMOTION_PLUGIN_MANAGEMENT_FLAGS BMOTION_PLUGIN_MANAGEMENT_CALLBACK BMOTION_PLUGIN_MANAGEMENT_HELPCALLBACK

	foreach key [array names bMotion_plugins_management] {
		set val $bMotion_plugins_management($key)
		set rexp [lindex $val $BMOTION_PLUGIN_MANAGEMENT_MATCH]
		set flags [lindex $val $BMOTION_PLUGIN_MANAGEMENT_FLAGS]
		set callback [lindex $val $BMOTION_PLUGIN_MANAGEMENT_CALLBACK]
		if [regexp -nocase $rexp $text] {
			return [list $flags $callback]
		}
	}
	return ""
}

#find a management plugin's help callback
proc bMotion_plugin_find_management_help { name } {
	global bMotion_plugins_management
	global BMOTION_PLUGIN_MANAGEMENT_MATCH BMOTION_PLUGIN_MANAGEMENT_FLAGS BMOTION_PLUGIN_MANAGEMENT_CALLBACK BMOTION_PLUGIN_MANAGEMENT_HELPCALLBACK

	foreach key [array names bMotion_plugins_management] {
		if [string match -nocase $name $key] {
			set blah $bMotion_plugins_management($key)
			set helpcallback [lindex $blah $BMOTION_PLUGIN_MANAGEMENT_HELPCALLBACK]
			return $helpcallback
		}
	}
	return ""
}

#
# Load a complex plugin
proc bMotion_plugin_add_complex { id match chance callback language } {
	global bMotion_plugins_complex plugins bMotion_testing bMotion_noplugins bMotionCache

	if {$bMotion_testing == 0} {
		catch {
			set test $bMotion_plugins_complex($id)
			bMotion_log "plugins" "WARN" "bMotion: ALERT! Complex plugin $id is defined more than once"
			return 0
		}
		if [bMotion_plugin_check_allowed "complex:$id"] {
			set bMotion_plugins_complex($id) [list $match $chance $callback $language ""]

			bMotion_log "plugins" "DEBUG" "bMotion: added complex plugin: $id"
			append plugins "$id,"
			set bMotionCache(compiled) 0
			return 1
		}
		bMotion_log "plugins" "INFO" "bMotion: ignoring disallowed plugin complex:$id"
		set bMotion_noplugins 1
	}
}

#
# Find a complex plugin plugin
proc bMotion_plugin_find_complex { text lang { debug 0 }} {
	global bMotion_plugins_complex botnicks
	global BMOTION_PLUGIN_COMPLEX_MATCH BMOTION_PLUGIN_COMPLEX_CHANCE BMOTION_PLUGIN_COMPLEX_CALLBACK BMOTION_PLUGIN_COMPLEX_LANGUAGE BMOTION_PLUGIN_COMPLEX_COMPILED

	set result [list]

	bMotion_log "plugins" "TRACE" "bMotion_plugin_find_complex $text $lang $debug"

	set bias [bMotion_setting_get "bias"]
	if {$bias == ""} {
		set bias 1
	}

	bMotion_compile_matches

	foreach key [lsort [array names bMotion_plugins_complex]] {
		set val $bMotion_plugins_complex($key)
		set rexp [lindex $val $BMOTION_PLUGIN_COMPLEX_COMPILED]
		set callback [lindex $val $BMOTION_PLUGIN_COMPLEX_CALLBACK]
		set language [lindex $val $BMOTION_PLUGIN_COMPLEX_LANGUAGE]

		if {[string match $lang $language] || ($language == "any") || ($language == "all")} {
			if [regexp -nocase $rexp $text] {
				set chance [lindex $val $BMOTION_PLUGIN_COMPLEX_CHANCE]
				set c [rand 100]
				if {$debug} {
					set c 0
				}
				set chance [expr $chance * $bias]
				bMotion_log "plugins" "DEBUG" "matched complex:$key, chance is $chance, c is $c"
				if {$chance > $c} {
					bMotion_log "DEBUG" "firing complex plugin $key"
					lappend result $callback
				}
			}
		}
	}
	return $result
}


#
# Load an output plugin
proc bMotion_plugin_add_output { id callback enabled language { priority 11 } } {
	global bMotion_plugins_output plugins bMotion_testing bMotion_noplugins

	if {$bMotion_testing == 0} {
		catch {
			set test $bMotion_plugins_output($id)
			bMotion_log "plugins" "WARN" "bMotion: ALERT! Output plugin $id is defined more than once"
			return 0
		}
		if [bMotion_plugin_check_allowed "output:$id"] {
			set bMotion_plugins_output($id) [list $callback $enabled $language $priority]
			bMotion_log "plugins" "DEBUG" "bMotion: added output plugin: $id"
			append plugins "$id,"
			set bMotion_plugins_output_perchan($id) [list ]
			return 1
		}
		bMotion_log "plugins" "INFO" "bMotion: ignoring disallowed plugin output:$id"
		set bMotion_noplugins 1
	}
}

#
# Return a list of callbacks of output plugins
# Sorted by priority then name
# Includes plugins only enabled for the given channel
proc bMotion_plugin_find_output { lang { channel "" } { min_priority 0} { max_priority 100 } {name "" } } {
	global bMotion_plugins_output botnicks
	global bMotion_plugins_output_perchan
	global BMOTION_PLUGIN_OUTPUT_PRIORITY BMOTION_PLUGIN_OUTPUT_ENABLED BMOTION_PLUGIN_OUTPUT_LANGUAGE BMOTION_PLUGIN_OUTPUT_CALLBACK

	set result [list]

	bMotion_log "plugins" "TRACE" "bMotion_plugin_find_output lang=$lang channel=$channel min=$min_priority max=$max_priority name=$name"

	foreach key [lsort [array names bMotion_plugins_output]] {
		set val $bMotion_plugins_output($key)
		set callback [lindex $val $BMOTION_PLUGIN_OUTPUT_CALLBACK]
		set enabled [lindex $val $BMOTION_PLUGIN_OUTPUT_ENABLED]
		set language [lindex $val $BMOTION_PLUGIN_OUTPUT_LANGUAGE]
		set priority [lindex $val $BMOTION_PLUGIN_OUTPUT_PRIORITY]

		if {($name != "") && ($name != $key)} {
			bMotion_log "plugins" "TRACE" "macro: ignoring $key on name"
			continue
		}

		if {!(($priority >= $min_priority) && ($priority <= $max_priority))} {
			bMotion_log "plugins" "TRACE" "macro: ignoring $key on priority"
			continue
		}

		if {(![string match $lang $language] && ($language != "any") && ($language != "all"))} {
			bMotion_log "plugins" "TRACE" "macro: ignoring $key on language"
			bMotion_log "plugins" "TRACE" "macro: plugin is $language, want $lang"
			continue
		}

		if {$enabled == 1} {
			lappend result [list $callback $priority]
		} else {
			bMotion_log "plugins" "TRACE" "Searching $key for channel $channel"
			if {$channel != ""} {
				catch {
					set chanlist $bMotion_plugins_output_perchan($key)
					if {[lsearch $chanlist $channel] > -1} {
						lappend result [list $callback $priority]
						bMotion_log "plugins" "TRACE" "Plugin $key is enabled for $channel"
					}
				}
			}
		}
	}

	# Sort by priority
	set result [lsort -index 1 $result]
	set result2 [list]
	foreach entry $result {
		lappend result2 [lindex $entry 0]
	}

	bMotion_log "plugins" "DEBUG" "Returning list of output plugins for $channel: $result2"
	return $result2
}

#
# Globally enable or disable an output plugin
proc bMotion_plugin_set_output { id enabled } {
	global bMotion_plugins_output
	global BMOTION_PLUGIN_OUTPUT_ENABLED

	if {($enabled == 0) || ($enabled == 1)} {
		lset bMotion_plugins_output($id) $BMOTION_PLUGIN_OUTPUT_ENABLED $enabled
		return 1
	}
	return 0
}

#
# Enable or disable an output plugin on a channel
proc bMotion_plugin_set_output_channel { id channel enabled } {
	global bMotion_plugins_output_perchan
	set channel [string tolower $channel]

	set current [list]
	catch {
		set current $bMotion_plugins_output_perchan($id)
	}
	if {$enabled == 1} {
		set current [lappend current $channel]
	} else {
		set index [lsearch $current $channel]
		if {$index > -1} {
			set current [lreplace $current $index $index]
		}
	}
	set current [lsort -unique $current]

	set bMotion_plugins_output_perchan($id) $current
	return 1
}


## Load a simple action plugin
proc bMotion_plugin_add_action_simple { id match chance response language } {
	global bMotion_plugins_action_simple plugins bMotion_testing bMotion_noplugins bMotionCache

	if {$bMotion_testing == 0} {
		catch {
			set test $bMotion_plugins_action_simple($id)
			bMotion_log "plugins" "DEBUG" "bMotion: ALERT! Simple action plugin $id is defined more than once"
			return 0
		}
		if [bMotion_plugin_check_allowed "action_simple:$id"] {
			set bMotion_plugins_action_simple($id) [list $match $chance $response $language ""]
			bMotion_log "plugins" "INFO" "bMotion: added simple action plugin: $id"
			append plugins "$id,"
			set bMotionCache(compiled) 0
			return 1
		}
		bMotion_log "plugins" "INFO" "bMotion: ignoring disallowed plugin action_simple:$id"
		set bMotion_noplugins 1
	}
}


## Find a simple action plugin
proc bMotion_plugin_find_action_simple { text lang { debug 0 } } {
	global bMotion_plugins_action_simple botnicks 
	global BMOTION_PLUGIN_SIMPLE_MATCH BMOTION_PLUGIN_SIMPLE_CHANCE BMOTION_PLUGIN_SIMPLE_RESPONSE BMOTION_PLUGIN_SIMPLE_LANGUAGE BMOTION_PLUGIN_SIMPLE_COMPILED

	bMotion_compile_matches

	foreach key [lsort [array names bMotion_plugins_action_simple]] {
		set val $bMotion_plugins_action_simple($key)
		set language [lindex $val $BMOTION_PLUGIN_SIMPLE_LANGUAGE]
		if {[string match $lang $language] || ($language == "any")|| ($language == "all")} {
			set rexp [lindex $val $BMOTION_PLUGIN_SIMPLE_COMPILED]
			if [regexp -nocase $rexp $text] {
				set chance [lindex $val $BMOTION_PLUGIN_SIMPLE_CHANCE]
				set c [rand 100]
				if {$debug} { 
					set c 0
				}
				if {$chance > $c} {
					set response [lindex $val $BMOTION_PLUGIN_SIMPLE_RESPONSE]
					return $response
				}
			}
		}
	}
	return ""
}


## Load a complex action plugin
proc bMotion_plugin_add_action_complex { id match chance callback language } {
	global bMotion_plugins_action_complex plugins bMotion_testing bMotion_noplugins bMotionCache

	if {$bMotion_testing == 0} {
		catch {
			set test $bMotion_plugins_action_complex($id)
			bMotion_log "plugins" "WARN" "bMotion: ALERT! Complex action plugin $id is defined more than once"
			return 0
		}
		if [bMotion_plugin_check_allowed "action_complex:$id"] {
			set bMotion_plugins_action_complex($id) [list $match $chance $callback $language ""]
			bMotion_log "plugins" "INFO" "bMotion: added complex action plugin: $id"
			append plugins "$id,"
			set bMotionCache(compiled) 0
			return 1
		}
		bMotion_log "plugins" "DEBUG" "bMotion: ignoring disallowed plugin action_complex:$id"
		set bMotion_noplugins 1
	}
}

## Find a complex action plugin plugin
proc bMotion_plugin_find_action_complex { text lang { debug 0 } } {
	global bMotion_plugins_action_complex botnicks
	global BMOTION_PLUGIN_COMPLEX_MATCH BMOTION_PLUGIN_COMPLEX_CHANCE BMOTION_PLUGIN_COMPLEX_CALLBACK BMOTION_PLUGIN_COMPLEX_LANGUAGE BMOTION_PLUGIN_COMPLEX_COMPILED

	set result [list]

	bMotion_compile_matches

	foreach key [lsort [array names bMotion_plugins_action_complex]] {
		set val $bMotion_plugins_action_complex($key)
		set language [lindex $val $BMOTION_PLUGIN_COMPLEX_LANGUAGE]
		if {[string match $language $lang] || ($language == "any")|| ($language == "all")} {
			set rexp [lindex $val $BMOTION_PLUGIN_COMPLEX_COMPILED]
			if [regexp -nocase $rexp $text] {
				set chance [lindex $val $BMOTION_PLUGIN_COMPLEX_CHANCE]
				bMotion_log "plugins" "DEBUG" "matched action complex plugin $key"
				set c [rand 100]
				if {$debug} {
					set c 0
				}
				if {$chance > $c} {
					set callback [lindex $val $BMOTION_PLUGIN_COMPLEX_CALLBACK]
					lappend result $callback
				}
			}
		}
	}
	return $result
}


###############################################################################

proc bMotion_plugin_check_depend { depends } {
	#pass a string in the format "type:plugin,type:plugin,..."
	if {$depends == ""} {
		return 1
	}

	set result 1

	set blah [split $depends ","]
	foreach depend $blah {
		set blah2 [split $depend ":"]
		set t [lindex $blah2 0]
		set id [lindex $blah2 1]
		set a "bMotion_plugins_$t"
		upvar #0 $a ar
		bMotion_log "plugins" "TRACE" "bMotion: checking $a for $id ..."
		set temp [array names ar $id]
		if {[llength $temp] == 0} {
			set result 0
			bMotion_log "plugins" "TRACE" "bMotion: Missing dependency $t:$id"
		}
	}
	return $result
}



###############################################################################

proc bMotion_plugin_check_allowed { name } {
	#pass a string in the format "type:plugin"
	#setting in config should be "type:plugin,type:plugin,..."
	global bMotionSettings

	set disallowed ""

	catch {
		set disallowed $bMotionSettings(noPlugin)
	}

	if {$disallowed == ""} {
		return 1
	}

	bMotion_log "plugins" "DEBUG" "bMotion: checking $name against $disallowed"

	set blah [split $disallowed ","]
	foreach plugin $blah {
		if {$plugin == $name} {
			return 0
		}
	}
	return 1
}

################################################################################

## dev: simsea
## Load an irc event response plugin
proc bMotion_plugin_add_irc_event { id type match chance callback language } {
	if {![regexp -nocase "nick|join|quit|part|split" $type]} {
		bMotion_log "plugins" "ERROR" "bMotion: ALERT! IRC Event plugin $id has an invalid type $type"
		return 0
	}

	global bMotion_plugins_irc_event plugins bMotion_testing bMotion_noplugins
	if {$bMotion_testing == 0} {
		catch {
			set test $bMotion_plugins_irc_event($id)
			bMotion_log "plugins" "WARN" "bMotion: ALERT! IRC Event plugin $id is defined more than once"
			return 0
		}
		if [bMotion_plugin_check_allowed "irc:$id"] {
			set bMotion_plugins_irc_event($id) [list $type $match $chance $callback $language]
			bMotion_log "plugins" "INFO" "bMotion: added IRC event plugin: $id"
			append plugins "$id,"
			return 1
		}
		bMotion_log "plugins" "INFO" "bMotion: ignoring disallowed plugin irc:$id"
		set bMotion_noplugins 1
	}
}

## Find an IRC Event response plugin plugin
proc bMotion_plugin_find_irc_event { text type lang { debug 0 } } {
	if {![regexp -nocase "nick|join|quit|part|split" $type]} {
		bMotion_log "plugins" "ERROR" "bMotion: IRC Event search type $type is invalid"
		return 0
	}
	global bMotion_plugins_irc_event botnicks
	global BMOTION_PLUGIN_EVENT_TYPE BMOTION_PLUGIN_EVENT_MATCH BMOTION_PLUGIN_EVENT_CHANCE BMOTION_PLUGIN_EVENT_CALLBACK BMOTION_PLUGIN_EVENT_LANGUAGE
	set s [lsort [array names bMotion_plugins_irc_event]]
	set result [list]

	foreach key $s {
		set val $bMotion_plugins_irc_event($key)
		set etype [lindex $val $BMOTION_PLUGIN_EVENT_TYPE]
		if {[string match $type $etype]} {
			set language [lindex $val $BMOTION_PLUGIN_EVENT_LANGUAGE]
			if {[string match $language $lang] || ($language == "any") || ($language == "all")} {
				set rexp [lindex $val $BMOTION_PLUGIN_EVENT_MATCH]
				if [regexp -nocase $rexp $text] {
					set chance [lindex $val $BMOTION_PLUGIN_EVENT_CHANCE]
					set c [rand 100]
					if {$debug} {
						set c 0
					}
					if {$chance > $c} {
						set callback [lindex $val $BMOTION_PLUGIN_EVENT_CALLBACK]
						lappend result $callback
					}
				}
			}
		}
	}
	return $result
}


################################################################################

## Load the simple plugins
catch { source "$bMotionPlugins/simple.tcl" }

## Load the admin (management) plugins
catch { source "$bMotionPlugins/admin.tcl" }

## Load the complex plugins
catch { source "$bMotionPlugins/complex.tcl" }

## Load the output plugins
catch { source "$bMotionPlugins/output.tcl" }

## Load the simple action plugins
catch { source "$bMotionPlugins/action_simple.tcl" }

## Load the complex action plugins
catch { source "$bMotionPlugins/action_complex.tcl" }

## Load the irc event plugins
catch { source "$bMotionPlugins/irc_event.tcl" }

## clean this up, not used again
unset bMotion_noplugins

### null plugin routine for faking plugins
proc bMotion_plugin_null { {a ""} {b ""} {c ""} {d ""} {e ""} } {
	return 0
}

# bMotion_plugin_history_add
#
# adds a plugin name to the history list, keeping the list to 10 items
# will not add the plugin if the last one is identical
proc bMotion_plugin_history_add { channel type plugin } {
	global bMotionPluginHistory

	set historyEntry "$channel:$type:$plugin"
	if {$historyEntry == [lindex $bMotionPluginHistory end]} {
		bMotion_log "plugins" "DEBUG" "Skipping duplicate plugin history entry $historyEntry"
		return 0
	}

	bMotion_log "plugins" "DEBUG" "Added $historyEntry to plugin history"
	lappend bMotionPluginHistory $historyEntry

	if {[llength $bMotionPluginHistory] > 10} {
		set bMotionPluginHistory [lreplace $bMotionPluginHistory end-10 end]
	}
	return 1
}

# bMotion_plugin_history_check
#
# returns 0 if the plugin hasn't fired recently in the channel
# else returns position in list
proc bMotion_plugin_history_check { channel type plugin } {
	global bMotionPluginHistory

	return [expr [lsearch $bMotionPluginHistory "$channel:$type:$plugin"] + 1]
}

proc bMotion_compile_matches { } {
	bMotion_log "plugins" "TRACE" "bMotion_compile_matches"

	global bMotionCache bMotion_plugins_complex botnicks bMotion_plugins_action_complex
	global bMotion_plugins_simple bMotion_plugins_action_simple
	global BMOTION_PLUGIN_COMPLEX_MATCH BMOTION_PLUGIN_COMPLEX_COMPILED
	global BMOTION_PLUGIN_SIMPLE_MATCH BMOTION_PLUGIN_SIMPLE_COMPILED

	if {$bMotionCache(compiled)} {
		return
	}

	bMotion_check_botnicks

	foreach key [lsort [array names bMotion_plugins_complex]] {
		set val $bMotion_plugins_complex($key)
		set rexp [lindex $val $BMOTION_PLUGIN_COMPLEX_MATCH]

		set compiled [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
		bMotion_log "plugins" "DEBUG" "Compiled complex plugin $rexp to $compiled for $key"
		lset val $BMOTION_PLUGIN_COMPLEX_COMPILED $compiled
		set bMotion_plugins_complex($key) $val
	}

	foreach key [lsort [array names bMotion_plugins_action_complex]] {
		set val $bMotion_plugins_action_complex($key)
		set rexp [lindex $val $BMOTION_PLUGIN_COMPLEX_MATCH]

		set compiled [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
		bMotion_log "plugins" "DEBUG" "Compiled complex action plugin $rexp to $compiled for $key"
		lset val $BMOTION_PLUGIN_COMPLEX_COMPILED $compiled
		set bMotion_plugins_action_complex($key) $val
	}

	foreach key [lsort [array names bMotion_plugins_simple]] {
		set val $bMotion_plugins_simple($key)
		set rexp [lindex $val $BMOTION_PLUGIN_SIMPLE_MATCH]

		set compiled [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
		bMotion_log "plugins" "DEBUG" "Compiled simple plugin $rexp to $compiled for $key"
		lset val $BMOTION_PLUGIN_SIMPLE_COMPILED $compiled
		set bMotion_plugins_simple($key) $val
	}

	foreach key [lsort [array names bMotion_plugins_action_simple]] {
		set val $bMotion_plugins_action_simple($key)
		set rexp [lindex $val $BMOTION_PLUGIN_SIMPLE_MATCH]

		set compiled [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
		bMotion_log "plugins" "DEBUG" "Compiled simple action plugin $rexp to $compiled for $key"
		lset val $BMOTION_PLUGIN_SIMPLE_COMPILED $compiled
		set bMotion_plugins_action_simple($key) $val
	}

	set bMotionCache(compiled) 1
}

bMotion_log "plugins" "INFO" "bMotion: plugins module loaded"

