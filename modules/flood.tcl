# bMotion - Flood checking
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

# We're going to track flooding PER NICK globally, not per channel
# If someone's flooding us in one place, we'll handle it for all channels
# to stop them being annoying

# HOW IT WORKS
#
# Track a score for each nick
# Reduce the scores by 1 every 30 seconds
# Matching a plugin is one point
# Matching the SAME plugin as before is 3
# Going over 7 will make the bot ignore 50% of what you would trigger
# Going over 15 cuts you out completely

# Message levels: 
#	log: Flood checks
#	  d: flood ticks
#	  2: flood additions/subtractions

if {![info exists bMotion_flood_info]} {
	set bMotion_flood_info(_) 0
	set bMotion_flood_last(_) ""
	set bMotion_flood_lasttext(_) ""
	set bMotion_flood_note ""
	set bMotion_flood_undo 0
}

proc bMotion_flood_tick { } { 
	bMotion_putloglev 4 * "bMotion: flood tick"
	utimer 30 bMotion_flood_tick
	
	#tick all values down one, to zero
	global bMotion_flood_info bMotion_flood_last bMotion_flood_lasttext
	set stats ""
	foreach element [array names bMotion_flood_info] {
		set val $bMotion_flood_info($element)
		incr val -2
		if {$val < 0} {
			catch {
				unset bMotion_flood_info($element)
			}
			catch {
				unset bMotion_flood_last($element)
			}
			catch {
				unset bMotion_flood_lasttext($element)
			}
			bMotion_putloglev 2 * "bMotion: flood tick: $element removed"
		} else {
			append stats "$element:\002$val\002 "
			set bMotion_flood_info($element) $val
		}
	}
	if {$stats != ""} {
		bMotion_putloglev d * "bMotion: flood tick: $stats"
	}
}


proc bMotion_flood_add { nick { callback "" } { text "" } } {
	global bMotion_flood_info bMotion_flood_last bMotion_flood_lasttext bMotion_flood_last bMotion_flood_undo

	set val 1
	if {[string index $nick 0] != "#"} {
		if [validuser $nick] {
			set handle $nick
		} else {
			set handle [nick2hand $nick]
			if {$handle == "*"} {
				set handle $nick
			}
			bMotion_putloglev d * "Using handle $handle as flood target (was $nick)"
		}
	} else {
		bMotion_putloglev d * "Using channel $nick as flood target"
		set handle $nick
	}
	set lastCallback ""
	catch {
		set lastCallback $bMotion_flood_last($handle)
	}
	if {$callback != ""} {
		set bMotion_flood_last($handle) $callback
		if {$lastCallback == $callback} {
		#naughty
			set val 3
		}
	}

	set lastText ""
	catch {
		set lastText $bMotion_flood_lasttext($handle)
	}
	if {$text != ""} {
		set bMotion_flood_lasttext($handle) $text
		#putlog "now: $text, last: $lastText"
		if {$lastText == $text} {
		#naughty
		incr val 2
		}
		}

		set flood 0
		catch {
		set flood $bMotion_flood_info($handle)
		}
		set oldflood $flood
		incr flood $val
		if {$flood > 40} {
		set flood 40
	}
	bMotion_putloglev 2 * "bMotion: flood $oldflood -- $val --> $flood for $nick"
	bMotion_putloglev 3 * "flood was added by plugin $callback"

	set bMotion_flood_info($handle) $flood
	set bMotion_flood_undo $val
}


proc bMotion_flood_clear { nick } {
	global bMotion_flood_info bMotion_flood_last
	bMotion_putloglev d * "Cleared flood for $nick"
	set bMotion_flood_info($nick) 0
	set bMotion_flood_last($nick) ""
}


proc bMotion_flood_remove { nick } {
	global bMotion_flood_info 
	set val 1
	if [validuser $nick] {
		set handle $nick
	} else {
		set handle [nick2hand $nick]
		if {$handle == "*"} {
			set handle $nick
		}
	}
	set flood 0
	catch {
		set flood $bMotion_flood_info($handle)
	}
	incr flood -1
	if {$flood < 0} {
		return 0
	}
	bMotion_putloglev 2 * "bMotion: flood removed 1 from $nick, now $flood"
	set bMotion_flood_info($handle) $flood
}


proc bMotion_flood_undo { nick } {
	global bMotion_flood_undo bMotion_flood_info bMotion_flood_lasttext
	set val $bMotion_flood_undo

	if {$val <= 1} {
		return 0
	}

	if [validuser $nick] {
		set handle $nick
	} else {
		set handle [nick2hand $nick]
		if {$handle == "*"} {
			set handle $nick
		}
	}

	set flood 0
	catch {
		set flood $bMotion_flood_info($handle)
	}
	set oldflood $flood
	incr flood [expr 0 - $val]
	if {$flood < 0} {
		set flood 0
	}

	set bMotion_flood_info($handle) $flood
	set bMotion_flood_lasttext($handle) ""
	set bMotion_flood_undo 1
	bMotion_putloglev 2 * "bMotion: undid flood $oldflood -- $val --> $flood from $nick"
	return 0
}


proc bMotion_flood_get { nick } {
	global bMotion_flood_info
	if {[string index $nick 0] != "#"} {
		if [validuser $nick] {
			set handle $nick
		} else {
			set handle [nick2hand $nick]
			if {$handle == "*"} {
				set handle $nick
			}
		}
	} else {
		set handle $nick
	}
	set flood 0
	catch {
		set flood $bMotion_flood_info($handle)
	}
	return $flood
}


proc bMotion_flood_check { nick } {
	if { [bMotion_setting_get "disableFloodChecks"] != "" } {
		if { [bMotion_setting_get "disableFloodChecks"] == 1 } {
			return 0
		}  
	}  

	if {[bMotion_setting_get "bitlbee"]} {
		return 0
	}

	bMotion_putloglev 3 * "checking flood for $nick"
	set flood [bMotion_flood_get $nick]
	set chance 2

	if {[string index $nick 0] == "#"} {
		set is_chan 1
	} else {
		set is_chan 0
	}

	if {!$is_chan} {
		if {$flood > 35} {
			set chance -1
		}

		if {$flood > 25} {
			set chance -1
		}

		if {$flood > 15} {
			set chance 1
		}
		set r [rand 2]
		if {!($r < $chance)} {
			putlog "bMotion: FLOOD check on $nick (http://www.bmotion.net:8000/bmotion/wiki/FAQDisableFlood)"
			return 1
		}
	} else {
		if {$flood > 35} {
			putlog "bMotion: FLOOD protection for $nick (http://www.bmotion.net:8000/bmotion/wiki/FAQDisableFlood)"
			return 1
		}
	}
	return 0
}


utimer 30 bMotion_flood_tick
