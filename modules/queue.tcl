#bMotion - queue functions
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

bMotion_log_add_category "queue"

#A rehash should kill the queue
set bMotion_queue [list]
set bMotion_queue_runny 1

# queue format is:
#  list of:
#		 int: number of seconds until line should be output
#		 str: target
#		 str: content


# bMotion_queue_run
#
# Processes the queue, reducing all the times by 1. If anything hits or goes below
# 0 then it is sent to output
# This also sends stuff to remote bots
proc bMotion_queue_run { {force 0} } {
	global bMotion_queue bMotion_queue_runny

	bMotion_log "queue" "DEBUG" "bMotion_queue_run $force"

	if {$bMotion_queue_runny == 0} {
		if {$force == 0} {
		#queue is frozen
			return 0
		} else {
			bMotion_log "queue" "DEBUG" "Running queue once while frozen"
		}
	}

	set tempqueue [list]
	bMotion_log "queue" "DEBUG" "Running output queue..."
	foreach item $bMotion_queue {
		set sec [lindex $item 0]
		incr sec -1
		set target [lindex $item 1]
		set content [lindex $item 2]
		if {$sec < 1} {
		#time to output this
			bMotion_log "queue" "DEBUG" "NOW $target :$content"
			if [regexp {^@([^@]+)?@(.+)} $content matches bot text] {
				if {$bot == ""} {
					bMotion_log "queue" "ERROR" "bMotion: WARNING - tried to send text to a null bot o_O"
				} else {
					bMotionSendSayChan $target $text $bot
				}
			} else {
				if {$content != ""} {
					if [bMotion_setting_get "bitlbee"] {
						global bMotionOriginalNick
						#make sure the line doesn't start with the nick already
						if {$bMotionOriginalNick == ""} {
							set bMotionOriginalNick [bMotion_choose_random_user $target 0 ""]
						}
						if {![regexp -nocase "^$bMotionOriginalNick:" $content]} {
							set content "$bMotionOriginalNick: $content"
						}
						set bMotionOriginalNick ""
						bMotion_log "queue" "DEBUG" "bitlbee outgoing: $content"
					}
					if {[bMotion_setting_get "outputpriority"] == 1} {
						putserv "PRIVMSG $target :$content"
					} else {
						puthelp "PRIVMSG $target :$content"
					}
					set bMotionCache($target,last) 1
				}
			}
		} else {
		#put it back into queue
			bMotion_log "queue" "TRACE" "${sec}s: $target :$content"
			lappend tempqueue [list $sec $target $content]
		}
	}
	set bMotion_queue $tempqueue
}


# bMotion_queue_get_delay
#
# Returns the number of seconds something to wait to be last in the queue
proc bMotion_queue_get_delay { } {
	global bMotion_queue
	return [expr 2 + [llength $bMotion_queue]]
}

# bMotion_queue_add
#
# Adds some output to the queue
proc bMotion_queue_add { target content {delay 0} } {
	global bMotion_queue

	#calculate line delay
	set delay [expr $delay == 0 ? [bMotion_queue_get_delay] : $delay]
	bMotion_log "queue" "DEBUG" "queuing output '$content' for '$target' with ${delay}s delay"
	lappend bMotion_queue [list $delay $target $content]
}

# bMotion_queue_add_now
#
# Adds some output to the head of the queue
proc bMotion_queue_add_now { target content } {
	global bMotion_queue

	#no delay
	set delay 0
	bMotion_log "queue" "DEBUG" "queuing output '$content' for '$target' with 0s delay"
	lappend bMotion_queue [list $delay $target $content]
}

# bMotion_queue_callback
#
# This is the timer function
proc bMotion_queue_callback { } {
	global bMotion_queue
	utimer 2 bMotion_queue_callback
	if {[llength $bMotion_queue] > 0} {
		bMotion_queue_run
	}
}

# bMotion_queue_size
#
# Get the size of the queue in an implementation-independent fashion
proc bMotion_queue_size { } {
	global bMotion_queue
	return [llength $bMotion_queue]
}

# bMotion_queue_flush
#
# Clears the queue
proc bMotion_queue_flush { } {
	global bMotion_queue
	set bMotion_queue [list]
}

# bMotion_queue_freeze
#
# Stops queue output
proc bMotion_queue_freeze { } {
	global bMotion_queue_runny

	set bMotion_queue_runny 0
	bMotion_log "queue" "INFO" "Freezing output queue"
}

proc bMotion_queue_thaw { } {
	global bMotion_queue_runny

	set bMotion_queue_runny 1
	bMotion_log "queue" "INFO" "Thawing output queue"
}

proc bMotion_queue_dupecheck { text channel } {
	global bMotion_queue

	bMotion_log "queue" "TRACE" "bMotion_queue_dupecheck $text"

	set text [string tolower $text]

	# TODO: maybe remove some punctuation, but not things like :)

	set tempqueue [list]

	foreach item $bMotion_queue {
		if {$channel != [lindex $item 1]} {
			lappend tempqueue $item
			continue
		}

		set content [string tolower [lindex $item 2]]

		if {$content == $text} {
			# delete this entry by setting it to nothing; the next queue run will remove it
			set item [lreplace $item 2 2 ""]
			bMotion_log "queue" "INFO" "removed item '$content' as it's similar to text '$text'"
		}

		lappend tempqueue $item
	}

	set bMotion_queue $tempqueue
}

# init timer
utimer 1 bMotion_queue_callback
