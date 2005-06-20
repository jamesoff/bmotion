# bMotion admin plugins
#
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

#                        name   regexp               flags   callback
bMotion_plugin_add_management "status" "^(status|info)"     t       bMotion_plugin_management_status "any"
bMotion_plugin_add_management "queue" "^queue"            n       bMotion_plugin_management_queue "any"
bMotion_plugin_add_management "parse" "^parse"            n       bMotion_plugin_management_parse "any"
bMotion_plugin_add_management "rehash" "^rehash"          n       bMotion_plugin_management_rehash "any"
bMotion_plugin_add_management "reload" "^reload"          n       bMotion_plugin_management_reload "any"
bMotion_plugin_add_management "settings" "^settings" n bMotion_plugin_management_settings "any"
bMotion_plugin_add_management "global" "^global" n bMotion_plugin_management_global

#################################################################################################################################
# Declare plugin functions

proc bMotion_plugin_management_status { handle { args "" } } {
  global bMotionInfo botnicks bMotionSettings bMotionVersion

  bMotion_putadmin "I am running bMotion $bMotionVersion"
  bMotion_putadmin "My gender is $bMotionInfo(gender), and I am $bMotionInfo(orientation)"
  bMotion_putadmin "Random stuff happens at least every [bMotion_setting_get minRandomDelay], at most every [bMotion_setting_get maxRandomDelay], and not if channel quiet for more than [bMotion_setting_get maxIdleGap] (mins)"
  bMotion_putadmin "My botnicks are /$botnicks/"
  if [bMotion_setting_get silence] {
  	bMotion_putadmin "Running silent"
  }
  bMotion_putadmin "Current queue size is [bMotion_queue_size]"
  return 0
}

proc bMotion_plugin_management_queue { handle { args "" }} {
  global bMotion_queue

  if {$args == ""} {
    #display queue
    bMotion_putadmin "Queue size: [expr [bMotion_queue_size] - 1] lines"
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

	putlog "Parsing '$arg', requested in $target"

	#we've been requested from a channel
	puthelp $target
	bMotionDoAction $target "somenick" $arg
	return 0
}

proc bMotion_plugin_management_rehash { handle } {
  global bMotionCache bMotion_testing bMotionRoot

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
  global bMotionCache bMotion_testing bMotionRoot

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
    return 0
  }

  if [string match -nocase "on" $text] {
    bMotion_putadmin "globally enabling bmotion"
    set bMotionGlobal 1
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
