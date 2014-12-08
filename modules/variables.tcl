# bMotion - Global variable init
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

# Defaults

# Mood stuff is in mood.tcl

proc bMotion_safe_set_array { name key value } {
	bMotion_log "variables" "TRACE" "bMotion_safe_set_array $name $key $value"

	global $name
	if {![info exists $name]} {
		bMotion_log "variables" "DEBUG" "variable $name does not exist, creating array"
		array set $name {}
	}

	if {![info exists ${name}($key)]} {
		bMotion_log "variables" "DEBUG" "key $key in $name does not exist, setting to $value"
		set ${name}($key) $value
	}
}

bMotion_safe_set_array got "tissues,nick" ""
bMotion_safe_set_array got "tissues,channel" ""
bMotion_safe_set_array got "coffee,nick" ""
bMotion_safe_set_array got "coffee,channel" ""
bMotion_safe_set_array got "bodyPaint,nick" ""
bMotion_safe_set_array got "bodyPaint,channel" ""
bMotion_safe_set_array got "dildo,count" 0
bMotion_safe_set_array got "dildo,style" ""

bMotion_safe_set_array bMotionInfo pokemon pikachu
bMotion_safe_set_array bMotionInfo cloaked 0
bMotion_safe_set_array bMotionInfo warp 0
bMotion_safe_set_array bMotionInfo impulse 0
bMotion_safe_set_array bMotionInfo leet 0
bMotion_safe_set_array bMotionInfo dutch 0
bMotion_safe_set_array bMotionInfo leetChance 3
bMotion_safe_set_array bMotionInfo silence 0
bMotion_safe_set_array bMotionInfo away 0
bMotion_safe_set_array bMotionInfo clothing 5

set bMotionCache(away) ""
set bMotionCache(lastGreeted) ""
set bMotionCache(lastHows) ""
set bMotionCache(lastDoneFor) ""
set bMotionCache(teamRocket) ""
set bMotionCache(lastLeft) ""
set bMotionCache(opme) ""
set bMotionCache(typos) 0
set bMotionCache(typoFix) ""
set bMotionCache(remoteBot) ""
set bMotionCache(randomUser) ""

set bMotion_typos [list]
set bMotion_typo_mutex ""

bMotion_plugins_settings_set "system" "lastPlugin" "" "" ""
bMotion_plugins_settings_set "system" "last_simple" "" "" ""

#this is set later
set botnicks ""

set arrcachearr ""
set arrcachenick ""
set colenMings [expr srand([clock clicks])]

set bMotionAdminFlag "n"

#typing queue
set bMotionQueue [list]
set bMotionQueueTimer 0

set bMotionThisText ""

#0 for off
set bMotionGlobal 1

set bMotionPluginHistory [list]

set bMotionChannels [list]

# 0 -> 1 -> 2 -> 0
set BMOTION_SLEEP(AWAKE) 0
set BMOTION_SLEEP(BEDTIME) 1
set BMOTION_SLEEP(ASLEEP) 2
set BMOTION_SLEEP(OVERSLEEPING) 3

# start off awake
set bMotionSettings(asleep) $BMOTION_SLEEP(AWAKE)
set bMotionTiredness 0

set bMotionDebug [list]

bMotion_log_add_category "variables"
