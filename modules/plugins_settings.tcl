## plugins settings engine for bMotion
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

bMotion_log_add_category "pluginsettings"

if {![info exists bMotion_plugins_settings]} {
	set bMotion_plugins_settings(dummy,setting,channel,nick) "dummy"
}

proc bMotion_plugins_settings_set { plugin setting channel nick val {timeout 0}} {

	if {$nick == ""} { set nick "_" }
	if {$channel == ""} { set channel "_" }
	if {$setting == ""} { 
		bMotion_log "pluginsettings" "WARN" "$plugin tried to save without giving a setting name"
		return 0
	}
	if {$plugin == ""} { 
		bMotion_log "pluginsettings" "WARN" "Unknown plugin trying to save a setting"
		return 0
	}

	set nick [string tolower $nick]
	set channel [string tolower $channel]
	set setting [string tolower $setting]
	set plugin [string tolower $plugin]

	if {$plugin == "dummy"} {
		return ""
	}

	bMotion_log "pluginsettings" "DEBUG" "Saving plugin setting $setting,$channel,$nick -> $val (from plugin $plugin)"
	if [bMotion_redis_available] {
		if {$timeout > 0} {
			bMotion_redis_cmd set psettings:$plugin:$setting:$channel:$nick $val EX $timeout
		} else {
			bMotion_redis_cmd set psettings:$plugin:$setting:$channel:$nick $val
		}
	} else {
		global bMotion_plugins_settings
		set bMotion_plugins_settings($plugin,$setting,$channel,$nick) $val
	}
	return 0
}

proc bMotion_plugins_settings_get { plugin setting channel nick } {

	if {$nick == ""} { set nick "_" }
	if {$channel == ""} { set channel "_" }
	if {$setting == ""} { 
		bMotion_log "pluginsettings" "WARN" "$plugin tried to get without giving a setting name"
		return 0
	}
	if {$plugin == ""} { 
		bMotion_log "pluginsettings" "WARN" "Unknown plugin trying to get a setting"
		return 0
	}

	set nick [string tolower $nick]
	set channel [string tolower $channel]
	set setting [string tolower $setting]
	set plugin [string tolower $plugin]

	if {$plugin == "dummy"} {
		return ""
	}

	if [bMotion_redis_available] {
		return [bMotion_redis_cmd get psettings:$plugin:$setting:$channel:$nick]
	}

	global bMotion_plugins_settings
	if [info exists bMotion_plugins_settings($plugin,$setting,$channel,$nick)] {
		return $bMotion_plugins_settings($plugin,$setting,$channel,$nick)
	}

	bMotion_log "pluginsettings" "INFO" "plugin $plugin tried to get non-existent value $setting,$channel,$nick"
	return ""
}
