# bMotion admin plugins
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#												 name		regexp							 flags	 callback
bMotion_plugin_add_management "status" "^(status|info)"			t				bMotion_plugin_management_status "any"
bMotion_plugin_add_management "queue" "^queue"						n				bMotion_plugin_management_queue "any"
bMotion_plugin_add_management "parse" "^parse"						n				bMotion_plugin_management_parse "any"
bMotion_plugin_add_management "rehash" "^rehash"					n				bMotion_plugin_management_rehash "any"
bMotion_plugin_add_management "reload" "^reload"					n				bMotion_plugin_management_reload "any"
bMotion_plugin_add_management "settings" "^settings" n bMotion_plugin_management_settings "any"
bMotion_plugin_add_management "global" "^global" n bMotion_plugin_management_global "any"
bMotion_plugin_add_management "interbot" "^interbot" n bMotion_plugin_management_interbot "any" bMotion_plugin_management_interbot_help
bMotion_plugin_add_management "flux" "^flux capacitors?" n bMotion_plugin_management_flux "any"
bMotion_plugin_add_management "away" "^away" n bMotion_plugin_management_away "any" bMotion_plugin_management_away_help
bMotion_plugin_add_management "debug" "^debug" n bMotion_plugin_management_debug "any" bMotion_plugin_management_debug_help

#################################################################################################################################
# Declare plugin functions

proc bMotion_plugin_management_status { handle { args "" } } {
	global bMotionInfo botnicks bMotionSettings bMotionVersion bMotionChannels BMOTION_SLEEP botnick
	bMotion_update_chanlist 

	set my_botnick [string toupper $botnick]

	bMotion_putadmin "I AM $my_botnick! I'm powered by bMotion $bMotionVersion. I'm $bMotionInfo(gender) and this week I have mostly been $bMotionInfo(orientation)."

	if {$botnicks == ""} {
		bMotion_check_botnicks
	}

	bMotion_putadmin "My botnicks are currently /$botnicks/."

	if {$args == "channels"} {
		bMotion_putadmin "I'm active on: $bMotionChannels"
	}

	if {[bMotion_setting_get "sleepy"]} {
		switch $bMotionSettings(asleep) {
			0 {
				bMotion_putadmin "I'm currently awake and my next bedtime is [clock format $bMotionSettings(sleepy_nextchange)]."
			}
			1 {
				bMotion_putadmin "I'm currently in my pajamas."
			}
			2 {
				bMotion_putadmin "I'm actually asleep right now. My alarm's set for [clock format $bMotionSettings(sleepy_nextchange)]."
			}
			default {
				bMotion_putadmin "I'm not really sure if I'm awake or what. My current sleep state is $bMotionSettings(asleep) and my next event is [clock format $bMotionSettings(sleepy_nextchange)], although who knows what'll happen then."
			}
		}
	} else {
		bMotion_putadmin "I am impervious to tiredness and never need to sleep."
	}

	bMotion_putadmin "Random stuff happens at least every [bMotion_setting_get minRandomDelay]min, at most every [bMotion_setting_get maxRandomDelay]min, and not if channel quiet for more than [bMotion_setting_get maxIdleGap]min. Active channels have a line in the last [bMotion_setting_get active_idle_sec]sec."
	if { [bMotion_setting_get "silence"] == 1 } {
		bMotion_putadmin "I am silent."
	}
	if { [bMotion_setting_get "away"] == 1 } {
		bMotion_putadmin "I am away."
	}

	global bMotion_loaded_settings_from
	bMotion_putadmin "I loaded my configuration from: $bMotion_loaded_settings_from"

	if [bMotion_redis_available] {
		bMotion_putadmin "I'm using a redis server."
		if {$args == "redis"} {
			bMotion_putadmin "My redis server is at [bMotion_setting_get redis_server]:[bMotion_setting_get redis_port] #[bMotion_setting_get redis_database]"
		}
	} else {
		bMotion_putadmin "I'm using legacy storage."
	}

	return 0
}

proc bMotion_plugin_management_queue { handle { args "" }} {
	global bMotion_queue

	if {$args == ""} {
	#display queue
		bMotion_putadmin "Queue size: [bMotion_queue_size] lines"
		foreach item $bMotion_queue {
			set sec [lindex $item 0]
			set target [lindex $item 1]
			set content [lindex $item 2]
			bMotion_putadmin "Delay $sec sec, target $target: $content"
		}
		return 0
	}

	if [regexp -nocase "clear|flush|delete|reset" $args] {
		bMotion_putadmin "Flushing queue..."
		bMotion_queue_flush
		return 0
	}

	if {$args == "freeze"} {
		bMotion_putadmin "Freezing queue..."
		bMotion_queue_freeze
		return 0
	}

	if {$args == "thaw"} {
		bMotion_putadmin "Thawing queue..."
		bMotion_queue_thaw
		return 0
	}

	if {$args == "run"} {
		bMotion_putadmin "Running queue..."
		bMotion_queue_run 1
		return 0
	}
}

proc bMotion_plugin_management_parse { handle { arg "" } } {
	if {$arg == ""} {
		bMotion_putadmin "You must supply something to parse"
		return 0
	}

	set output [bMotion_plugins_settings_get "admin" "type" "" ""]
	set target [bMotion_plugins_settings_get "admin" "target" "" ""]

	if {$output == ""} {
		return 0
	}

	if {($output == "dcc") || (![string match "#*" $target])} {
	#command syntax should be:
	# .bmotion parse #channel output
	if [regexp -nocase {(#[^ ]+) (.+)} $arg matches chan parse] {
		bMotionDoAction $chan "somenick" "\[parse\] $parse"
		bMotion_putadmin "Sent '$parse' to $chan"
		return 0
	}
	}

	#puthelp $target
	if [regexp {^-n ?([0-9]+) (.+)} $arg matches repeat parse] {
	putlog "Parsing '$parse' * $repeat in $target"
		for { set i 0 } { $i < $repeat } { incr i } {
	bMotionDoAction $target "somenick" $parse
	}
} else {
	putlog "Parsing '$arg', requested in $target"
	bMotionDoAction $target "somenick" $arg
}
return 0
}

proc bMotion_plugin_management_rehash { handle } {
	global bMotion_testing bMotionRoot

	#check we're not going to die
	catch {
		bMotion_putloglev d * "bMotion: Testing new code..."
		set bMotion_testing 1
		source "$bMotionRoot/bMotion.tcl"
	} msg

	if {$msg != ""} {
		putlog "bMotion: FATAL: Cannot rehash due to error: $msg"
		bMotion_putadmin "Cannot rehash due to error: $msg"
		return 0
	} else {
		bMotion_putloglev d * "bMotion: New code ok, rehashing..."
		bMotion_putadmin "Rehashing..."
		set bMotion_testing 0
		rehash
	}
}

proc bMotion_plugin_management_reload { handle } {
	global bMotion_testing bMotionRoot

	#check we're not going to die
	catch {
		bMotion_putloglev d * "bMotion: Testing new code..."
		set bMotion_testing 1
		source "$bMotionRoot/bMotion.tcl"
	} msg

	if {$msg != ""} {
		putlog "bMotion: FATAL: Cannot reload due to error: $msg"
		bMotion_putadmin "Cannot reload due to error: $msg"
		return 0
	} else {
		bMotion_putloglev d * "bMotion: New code ok, reloading..."
		bMotion_putadmin "Reloading bMotion..."
		set bMotion_testing 0
		source "$bMotionRoot/bMotion.tcl"
	}
}

proc bMotion_plugin_management_settings { handle { arg "" } } {
	global bMotion_plugins_settings

	if {$arg == "clear"} {
		if {![info exists bMotion_plugins_settings]} {
			unset bMotion_plugins_settings
			set bMotion_plugins_settings(dummy,setting,channel,nick) "dummy"
		}
		bMotion_putadmin "Cleared plugins settings array"
		return 0
	}

	if {$arg == "list"} {
		set s [array startsearch bMotion_plugins_settings]
		while {[set key [array nextelement bMotion_plugins_settings $s]] != ""} {
			bMotion_putadmin "$key = $bMotion_plugins_settings($key)"
		}
		array donesearch bMotion_plugins_settings $s
	}
}

proc bMotion_plugin_management_global { handle { text "" } } {
	global bMotionGlobal

	if [string match -nocase "off" $text] {
		bMotion_putadmin "globally disabling bmotion"
		set bMotionGlobal 0
		# force an election on the botnet
		bMotion_interbot_next_elect
		bMotion_interbot_send_bye
		return 0
	}

	if [string match -nocase "on" $text] {
		bMotion_putadmin "globally enabling bmotion"
		set bMotionGlobal 1
		bMotion_interbot_resync
		bMotion_interbot_next_elect
		return 0
	}

	if {$bMotionGlobal == 0} {
		bMotion_putadmin "bMotion is currently disabled"
	} else {
		bMotion_putadmin "bMotion is currently enabled"
	}
	bMotion_putadmin "use: global off|on"
	return 0
}

proc bMotion_plugin_management_interbot { handle { text "" } } {
	global bMotion_interbot_nextbot_nick

	if [regexp -nocase "next (#.+)" $text matches chan] {
		set next $bMotion_interbot_nextbot_nick($chan)
		if {$next == ""} {
			bMotion_putadmin "Next bot is unknown!"
		} else {
			bMotion_putadmin "Next bot for $chan is $next"
		}
	}

	if [regexp -nocase "elect (#.+)" $text matches chan] {
		bMotion_putadmin "Forcing election on $chan..."

		bMotion_interbot_next_elect_do $chan
	}

	if [regexp -nocase "bots (#.+)" $text matches chan] {

		bMotion_putadmin "Known bMotion bots on $chan: "
		bMotion_putadmin [bMotion_interbot_otherbots $chan]
	}

	if [regexp -nocase "enable" $text] {
		global bMotion_interbot_enable

		if {$bMotion_interbot_enable} {
			bMotion_putadmin "Interbot stuff is already enabled."
			return
		} else {
			set bMotion_interbot_enable 1
			bMotion_putadmin "Interbot stuff enabled."
			return
		}
	}

	if [regexp -nocase "disable" $text] {
		global bMotion_interbot_enable

		if {!$bMotion_interbot_enable} {
			bMotion_putadmin "Interbot stuff is already disabled."
			return
		} else {
			set bMotion_interbot_enable 0
			bMotion_putadmin "Interbot stuff disabled."
			return
		}
	}
}

proc bMotion_plugin_management_interbot_help { } {
	bMotion_putadmin "Manage the interbot communication stuff."
	bMotion_putadmin "	.bmotion interbot next #channel"
	bMotion_putadmin "		Report the next bot for #channel"
	bMotion_putadmin "	.bmotion interbot elect #channel"
	bMotion_putadmin "		Force an election for #channel"
	bMotion_putadmin "	.bmotion interbot bots #channel"
	bMotion_putadmin "		Report bots discovered in #channel"
	bMotion_putadmin "	.bmotion interbot enable"
	bMotion_putadmin "	.bmotion interbot disable"
	bMotion_putadmin "		Enable/disable interbot stuff entirely"
}

# um
proc bMotion_plugin_management_flux { handle { text "" } } {
	if {[string match "*off*" $text]} {
		bMotion_putadmin "i call it... MISTAR FUSION!"
		return
	}
	if {[string match "*on*" $text]} {
		bMotion_putadmin "ONE POINT TWENTY ONE JIGAWATS"
		return
	}
}

proc bMotion_plugin_management_away { handle { text "" } } {
	global bMotionInfo

	if {$text == ""} {
		if {$bMotionInfo(away)} {
			bMotion_putadmin "I am currently away."
		} else {
			bMotion_putadmin "I am not away."
		}
		return
	}

	if {$text == "off"} {
		bMotion_putadmin "Coming back from being away."
		set bMotionInfo(away) 0
		set bMotionInfo(silent) 0
		return
	}

	bMotion_putadmin "Use: .bmotion away [off]"
}

proc bMotion_plugin_management_away_help { } {
	bMotion_putadmin "Check and adjust the bot's away status"
	bMotion_putadmin "  .bmotion away"
	bMotion_putadmin "    Show if the bot is away or not"
	bMotion_putadmin "  .bmotion away off"
	bMotion_putadmin "    Make the bot be not-away"
}

proc bMotion_plugin_management_debug { handle { text "" } } {
	global bMotionDebug

	if {$text == "" } {
		if {[llength $bMotionDebug] == 0} {
			bMotion_putadmin "bMotion debug mode is currently disabled."
			return
		} else {
			bMotion_putadmin "bMotion debug mode is currently enabled on $bMotionDebug"
			return
		}
	}

	if [regexp -nocase {(on|off) ([#&][^ ]+)} $text matches toggle channel] {
		set channel [string tolower $channel]
		if {[string tolower $toggle] == "on"} {
			if {[lsearch $bMotionDebug $channel] > -1} {
				bMotion_putadmin "$channel already has the debug flag enabled."
				return
			}
			lappend bMotionDebug $channel
			bMotion_putadmin "Enabled debug mode for $channel"
			return
		} else {
			if {[lsearch $bMotionDebug $channel] == -1} {
				bMotion_putadmin "$channel does not have debug mode enabled."
				return
			}
			set index [lsearch $bMotionDebug $channel]
			set bMotionDebug [lreplace $bMotionDebug $index $index]
			bMotion_putadmin "Disabled debug mode for $channel"
			return
		}
	} else {
		bMotion_putadmin "Try .bmotion help debug"
	}
}

proc bMotion_plugin_management_debug_help { } {
	bMotion_putadmin "Enable and disable debug mode on channels. Debug mode makes all plugins fire at 100% chance and disables flood checking."
	bMotion_putadmin "  .bmotion debug"
	bMotion_putadmin "    Check the status of debug mode"
	bMotion_putadmin "  .bmotion debug on #channel"
	bMotion_putadmin "    Enable debug on #channel"
	bMotion_putadmin "  .bmotion debug off #channel"
	bMotion_putadmin "    Disable debug on #channel"
}
