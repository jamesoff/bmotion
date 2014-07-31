# bMotion - friendship handler
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

bMotion_log_add_category "friendship"

# get a nick's friendship rating, or 50 if we couldn't find them (or if they don't
# have a friendship yet
proc getFriendship { nick } {
	bMotion_log "friendship" "TRACE" "getFriendship $nick"

	if {![validuser $nick]} {
		set handle [nick2hand $nick]
		if {($handle == "*") || ($handle == "")} {
			bMotion_log "friendship" "DEBUG" "couldn't find a handle for $nick to get friendship, returning 50"
			return 50
		}
	} else {
		set handle $nick
	}

	set friendship 50

	if {$handle != "*"} {
		set friendship [getuser $handle XTRA friend]
		if {$friendship == ""} {
			setFriendship $nick 50	
			set friendship 50
		}
	}
	return $friendship
}

#
# get a handle's friendship, or 50 if unknown
proc getFriendshipHandle { handle } {
	bMotion_log "friendship" "TRACE" "getFriendshipHandle $handle"

	set friendship 50

	set friendship [getuser $handle XTRA friend]
	if {$friendship == ""} {
		setFriendship $handle 50	
		set friendship 50
	}
	return $friendship
}


# set friendship on a handle
proc setFriendshipHandle { handle friendship } {
	bMotion_log "friendship" "TRACE" "setFriendshipHandle $handle $friendship"

	if {$friendship > 100} {
		bMotion_log "friendship" "DEBUG" "friendship for $handle went over 100, capping back to 90"
		set friendship 90
	}

	if {$friendship < 1} {
		bMotion_log "friendship" "DEBUG" "friendship for $handle went under 1, capping back to 10"
		set friendship 10
	}

	setuser $handle XTRA friend $friendship
}


# set friendship on a nick, if we can find a matching handle for them
proc setFriendship { nick friendship } {
	bMotion_log "friendship" "TRACE" "setFriendship $nick $friendship"

	set handle [nick2hand $nick]

	if {($handle == "*") || ($handle == "")} {
		#perhaps it was already a handle
		if {![validuser $nick]} {
			bMotion_log "friendship" "DEBUG" "couldn't find a handle for $nick to set friendship."
			return 0
		}
		set handle $nick
	}

	setFriendshipHandle $handle $friendship
}


# drift someone's friendship by a given amount
proc driftFriendship { nick drift } {
	bMotion_log "friendship" "TRACE" "driftFriendship $nick $drift"

	set handle [nick2hand $nick]
	if {($handle == "*") || ($handle == "")} {
		bMotion_log "friendship" "DEBUG" "couldn't find a handle for $nick to drift friendship."
		return 50
	}

	set friendship [getFriendship $handle]
	incr friendship $drift
	setFriendship $nick $friendship
	bMotion_log "friendship" "INFO" "drifting friendship for $nick by $drift, now $friendship"
	return $friendship
}


# get all users with friendship values
proc getFriendsList { } {
	bMotion_log "friendship" "TRACE" "getFriendsList"

	set users [userlist]
	set r ""
	set best(name) ""
	set best(val) 0
	set worst(name) ""
	set worst(val) 100
	set count 0

	foreach user $users {
		set f [getuser $user XTRA friend]
		if {$f != ""} {
			append r "$user:$f "
		}
		if {$f > $best(val)} {
			set best(val) $f
			set best(name) $user
		}
		if {($f < $worst(val)) && ($f > 0)} {
			set worst(val) $f
			set worst(name) $user
		}
		incr count
		if {$count % 10 == 0} {
			append r "\r\n"
		}
	}
	if {$count == 0} {
		return "No friends :( so lonely"
	}
	if {$count == 1} {
		set r "Only 1 friend :(\r\n$r"
		return $r
	}
	set r "$count friends; Best friend: $best(name), worst friend: $worst(name). \r\n$r"
	return $r
}


# check if someone is liked enough to be a friend
proc bMotionIsFriend { nick } {
	bMotion_log "friendship" "TRACE" "bMotionIsFriend $nick"

	set friendship [getFriendship $nick]
	bMotion_log "friendship" "DEBUG" "friendship for $nick is $friendship"
	if {$friendship <= 40} {
		return 0
	}
	return 1
}		 


# tick everyone's friendship back a bit
proc bMotion_friendship_tick { min hr a b c } {
	bMotion_log "friendship" "TRACE" "bMotion_friendship_tick"

	set users [userlist]
	foreach user $users {
		set f [getuser $user XTRA friend]
		if {$f != ""} {
			bMotion_log "friendship" "TRACE" "$user is $f"
			if {$f > 60} {
				setuser $user XTRA friend [expr $f - 1]
			}

			if {$f < 40} {
				setuser $user XTRA friend [expr $f + 1]
			}
		}
	}
}

bind time - "00 * * * *" bMotion_friendship_tick

bMotion_log "friendship" "INFO" "friendship module loaded"
