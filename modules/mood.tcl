# bMotion - Mood handling
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

bMotion_log_add_category "mood"


# value is the current mood value
# min in the lowest it can be
# max is the highest it can be
# target is where it drifts towards every tick
# callback is executed when it is changed
set BMOTION_MOOD_VALUE    0
set BMOTION_MOOD_MIN      1
set BMOTION_MOOD_MAX      2
set BMOTION_MOOD_TARGET   3
set BMOTION_MOOD_CALLBACK 4

# array to hold our data
if {![array exists bMotion_moods]} {
	array set bMotion_moods [list]
}


proc bMotion_mood_init { name initial min max target callback } {
	global bMotion_moods

	bMotion_log "mood" "TRACE" "bMotion_mood_init $name $initial $min $max $target $callback"

	if {[llength [array get bMotion_moods $name]] > 0} {
		bMotion_log "mood" "DEBUG" "ignoring mood init for duplicate mood $name"
		return
	}

	if {($initial < $min) || ($initial > $max)} {
		bMotion_log "mood" "ERROR" "ignoring mood init for $name; initial value is out of bounds"
		return
	}

	if {($target < $min) || ($target > $max)} {
		bMotion_log "mood" "ERROR" "ignoring mood init for $name; target value is out of bounds"
		return
	}

	if {$name == ""} {
		bMotion_log "mood" "ERROR" "ignoring mood init for empty name"
		return
	}

	if {$min >= $max} {
		bMotion_log "mood" "ERROR" "ignoring mood init for $name; invalid min/max"
		return
	}

	array set bMotion_moods [list $name [list $initial $min $max $target $callback] ]
	bMotion_log "mood" "INFO" "initialised mood $name"
}


proc bMotionGetHappy {} {
	bMotion_mood_adjust happy 1
}


proc bMotionGetSad {} {
	bMotion_mood_adjust happy -1
}


proc bMotionGetHorny {} {
	bMotion_mood_adjust horny 1
}


proc bMotionGetUnHorny {} {
	bMotion_mood_adjust horny -1
}


proc bMotionGetLonely {} {
	bMotion_mood_adjust lonely 1
}


proc bMotionGetUnLonely {} {
	bMotion_mood_adjust lonely -1
}


proc checkmood {nick channel} {
	bMotion_log "mood" "ERROR" "call to checkmood"
	return
}


proc driftmood {} {
	bMotion_log "mood" "ERROR" "call to driftmood"
	return 
}


proc bMotion_mood_drift_timer { } {
	bMotion_log "mood" "TRACE" "bMotion_mood_drift_timer"
	timer 10 bMotion_mood_drift_timer
	bMotion_mood_drift
}


proc bMotion_mood_drift { } {
	bMotion_log "mood" "TRACE" "bMotion_mood_drift"
	global bMotion_moods
	global BMOTION_MOOD_VALUE BMOTION_MOOD_MIN BMOTION_MOOD_MAX BMOTION_MOOD_TARGET BMOTION_MOOD_CALLBACK

	set names [array names bMotion_moods]
	foreach mood $names {
		set mood_info $bMotion_moods($mood)
		set target [lindex $mood_info $BMOTION_MOOD_TARGET]
		set value [lindex $mood_info $BMOTION_MOOD_VALUE]

		if {$value == $target} {
			bMotion_log "mood" "DEBUG" "mood $mood is at target value of $target"
			continue
		}

		if {$value < $target} {
			bMotion_log "mood" "DEBUG" "mood $mood needs drifting up: $value < $target"
			incr value
		} else {
			bMotion_log "mood" "DEBUG" "mood $mood needs drifting down: $value > $target"
			incr value -1
		}

		set mood_info [lreplace $mood_info $BMOTION_MOOD_VALUE $BMOTION_MOOD_VALUE $value]
		bMotion_log "mood" "DEBUG" "mood $mood is now $mood_info"
		set bMotion_moods($mood) $mood_info 
	}
}


proc bMotion_mood_adjust { name change } {
	bMotion_log "mood" "TRACE" "bMotion_mood_adjust $name $change"
	global bMotion_moods
	global BMOTION_MOOD_VALUE BMOTION_MOOD_MIN BMOTION_MOOD_MAX BMOTION_MOOD_TARGET BMOTION_MOOD_CALLBACK

	if {[llength [array get bMotion_moods $name]] == 0} {
		bMotion_log "mood" "DEBUG" "ignoring mood change for $name"
		return
	}

	set mood_info $bMotion_moods($name)
	set value [lindex $mood_info $BMOTION_MOOD_VALUE]
	set min [lindex $mood_info $BMOTION_MOOD_MIN]
	set max [lindex $mood_info $BMOTION_MOOD_MAX]
	set callback [lindex $mood_info $BMOTION_MOOD_CALLBACK]

	bMotion_log "mood" "DEBUG" "adjusting $name from $value by $change"
	incr value $change

	if {$value > $max} {
		bMotion_log "mood" "DEBUG" "$name went too high; capping to $max"
		set value $max
	}

	if {$value < $min} {
		bMotion_log "mood" "DEBUG" "$name went too low; capping to $min"
		set value $min
	}

	set mood_info [lreplace $mood_info $BMOTION_MOOD_VALUE $BMOTION_MOOD_VALUE $value]
	set bMotion_moods($name) $mood_info

	if {[llength [info procs $callback]] > 0} {
		bMotion_log "mood" "DEBUG" "running callback $callback for $name"
		catch {
			$callback
		}
	}
}


## moodTimerStart: Used to start the mood drift timer when the script initialises
## and other timers now, too
proc moodTimerStart {} {
	bMotion_log "mood" "TRACE" "moodTimerStart"
	global mooddrifttimer
	if  {![info exists mooddrifttimer]} {
		timer 10 driftmood
		timer [expr [rand 30] + 3] doRandomStuff
		set mooddrifttimer 1
	}
	timer 10 bMotion_mood_drift_timer
}


proc moodhandler {handle idx arg} {
	bMotion_log "mood" "ERROR" "moodhandler"
	putidx $idx "Please use .bmotion mood"
}


proc pubm_moodhandler {nick host handle channel text} {
	bMotion_log "mood" "ERROR" "pubm_moodhandler $nick $host $handle $channel $text"
	if {![matchattr $handle n]} {
		return 0
	}

	global botnick

	bMotionDoAction $channel $nick "%%: Please use .bmotion $botnick mood"
	return 0
}


proc bMotion_mood_admin { handle { arg "" } } {
	bMotion_log "mood" "TRACE" "bMotion_mood_admin $handle $arg"
	global bMotion_moods
	global BMOTION_MOOD_VALUE BMOTION_MOOD_MIN BMOTION_MOOD_MAX BMOTION_MOOD_TARGET BMOTION_MOOD_CALLBACK

	if {($arg == "") || ($arg == "status")} {
		#output our mood
		bMotion_putadmin "Current mood status:"
		set names [array names bMotion_moods]
		foreach mood $names {
			set value [lindex $bMotion_moods($mood) $BMOTION_MOOD_VALUE]
			bMotion_putadmin "  $mood: $value"
		}
		return 0
	}

	if {$arg == "info"} {
	#output our mood
		bMotion_putadmin "Current mood configuration:"
		set names [array names bMotion_moods]
		foreach mood $names {
			set mood_info $bMotion_moods($mood)
			set value [lindex $mood_info $BMOTION_MOOD_VALUE]
			set min [lindex $mood_info $BMOTION_MOOD_MIN]
			set max [lindex $mood_info $BMOTION_MOOD_MAX]
			set callback [lindex $mood_info $BMOTION_MOOD_CALLBACK]
			set target [lindex $mood_info $BMOTION_MOOD_TARGET]

			if {$callback == ""} {
				set callback "(none)"
			}

			bMotion_putadmin "  $mood: $min < $value < $max; target $target; callback $callback"
		}
		return 0
	}

	if {$arg == "drift"} {
		bMotion_putadmin "Drifting mood values..."
		bMotion_mood_drift
		return 0
	}

	if {[regexp -nocase {set ([^ ]+) (-?[0-9]+)} $arg matches moodname moodval]} {
		if {$moodval < -30} {
			set moodval -30
			bMotion_putloglev d * "bMotion: mood $moodname went OOB, resetting to -30"
		}
		if {$moodval > 30} {
			bMotion_putloglev d * "bMotion: mood $moodname went OOB, resetting to 30"
			set moodval 30
		}

		set value [bMotion_mood_set $moodname $moodval]

		if {$value == ""} {
			bMotion_putadmin "Unknown mood"
			return 0
		}

		bMotion_putadmin "Value for mood $moodname is now $value"

		return 0
	}

	bMotion_putadmin "use: mood \[status|info|drift|set <name> <value>\]"
	return 0
}


proc bMotion_mood_set { name newvalue } {
	bMotion_log "mood" "TRACE" "bMotion_mood_set $name $newvalue"
	global bMotion_moods
	global BMOTION_MOOD_VALUE BMOTION_MOOD_MIN BMOTION_MOOD_MAX BMOTION_MOOD_TARGET BMOTION_MOOD_CALLBACK

	if {[llength [array get bMotion_moods $name]] == 0} {
		return ""
	}

	set mood_info $bMotion_moods($name)
	set mood_info [lreplace $mood_info $BMOTION_MOOD_VALUE $BMOTION_MOOD_VALUE $newvalue]
	set bMotion_moods($name) $mood_info

	return [lindex $bMotion_moods($name) $BMOTION_MOOD_VALUE]
}


proc bMotion_mood_get { name } {
	bMotion_log "mood" "TRACE" "bMotion_mood_get $name"
	global bMotion_moods
	global BMOTION_MOOD_VALUE BMOTION_MOOD_MIN BMOTION_MOOD_MAX BMOTION_MOOD_TARGET BMOTION_MOOD_CALLBACK

	if {[llength [array get bMotion_moods $name]] == 0} {
		return ""
	}

	return [lindex $bMotion_moods($name) $BMOTION_MOOD_VALUE]
}


proc bMotion_mood_admin_help { } {
	bMotion_putadmin "Controls the mood system:"
	bMotion_putadmin "  .bmotion mood [status]"
	bMotion_putadmin "    View a list of all moods and their values"
	bMotion_putadmin "  .bmotion mood set <name> <value>"
	bMotion_putadmin "    Set mood <name> to <value>. The neutral value is usually 0. Max/min is (-)30."
	bMotion_putadmin "  .bmotion mood drift"
	bMotion_putadmin "    Runs a mood tick."
	bMotion_putadmin "  .bmotion mood info"
	bMotion_putadmin "    Shows internal mood configuration"
}


if {$bMotion_testing == 0} {
	bMotion_plugin_add_management "mood" "^mood" n bMotion_mood_admin "any" bMotion_mood_admin_help
}

bMotion_mood_init 	happy 			0 	-30 	30 	0 	bMotion_mood_change_happy
bMotion_mood_init 	horny 			0 	-30 	30 	0 	bMotion_mood_change_horny
bMotion_mood_init 	lonely 			0 	-30 	30 	5 	bMotion_mood_change_lonely
bMotion_mood_init 	electricity 	0 	-30 	30 	2 	bMotion_mood_change_electricity
bMotion_mood_init 	stoned 			0 	-30 	30 	0 	bMotion_mood_change_stoned


bMotion_log "mood" "INFO" "mood module loaded"
