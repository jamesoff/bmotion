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
bMotion_plugin_add_admin "test" "^test"              n       "bMotion_plugin_admin_test" "any"
bMotion_plugin_add_admin "status" "^(status|info)"     t       "bMotion_plugin_admin_status" "any"
bMotion_plugin_add_admin "queue" "^queue"            n       "bMotion_plugin_admin_queue" "any"
bMotion_plugin_add_admin "parse" "^parse"            n       "bMotion_plugin_admin_parse" "any"
bMotion_plugin_add_admin "friends" "^friends(hip)?"  n       "bMotion_plugin_admin_friends" "any"
bMotion_plugin_add_admin "unbind votes" "^unbind votes" n    "bMotion_plugin_admin_unbindVotes" "any"
bMotion_plugin_add_admin "codesize" "^codesize"          n       "bMotion_plugin_admin_codesize" "any"
bMotion_plugin_add_admin "rehash" "^rehash"          n       "bMotion_plugin_admin_rehash" "any"
bMotion_plugin_add_admin "reload" "^reload"          n       "bMotion_plugin_admin_reload" "any"
bMotion_plugin_add_admin "settings_clear" "^settings clear" n bMotion_plugin_admin_settings_clear "any"

#################################################################################################################################
# Declare plugin functions

proc bMotion_plugin_admin_test { handle idx args } {
  putidx $idx "test: $handle $args"
}

proc bMotion_plugin_admin_status { handle idx args } {
  global bMotionInfo botnicks bMotionSettings bMotionVersion randomsinfo bMotionQueue
  set timezone [clock format [clock seconds] -format "%Z"]

  putidx $idx "I am running bMotion $bMotionVersion\r"
  putidx $idx "Using randoms file $randomsinfo\r"
  putidx $idx "My gender is $bMotionInfo(gender), and I am $bMotionInfo(orientation)\r"
  putidx $idx "Respond to everything is $bMotionInfo(balefire) (1 = on)\r"
  putidx $idx "Current pokemon is $bMotionInfo(pokemon)\r"
  putidx $idx "Random stuff happens at least every $bMotionInfo(minRandomDelay), at most every $bMotionInfo(maxRandomDelay), and not if channel quiet for more than $bMotionInfo(maxIdleGap) (mins)\r"
  putidx $idx "My botnicks are $botnicks ('.bmotion redo botnicks' to update)\r"
  putidx $idx "melMode $bMotionSettings(melMode) (1 = on)\r"
  putidx $idx "needI $bMotionSettings(needI) (1 = on)\r"
  if {$bMotionInfo(silence)} { putidx $idx "Running silent\r" }    
  putidx $idx "Current queue size is [llength $bMotionQueue]\r"
  return 0
}

proc bMotion_plugin_admin_queue { handle idx { args "" }} {
  global bMotionQueue

  if {$args == ""} {
    #display queue
    putidx $idx "Queue size: [llength $bMotionQueue]\r";
    set i 0
    foreach item $bMotionQueue {
      putidx $idx "$i: $item\r"
      incr i
    }
    return 0
  }

  if [regexp -nocase "clear|flush|delete|reset" $args] {
    putidx $idx "Flushing queue...\r";
    global bMotionQueue
    set bMotionQueue [list]
    return 0
  }
}

proc bMotion_plugin_admin_parse { handle idx arg } {
  if [regexp -nocase {(\[#!\][^ ]+)( (.+))} $arg matches channel pom txt] {
    bMotionDoAction $channel "" $txt
    putlog "bMotion: Parsed text from DCC chat"
  }
}

proc bMotion_plugin_admin_friends { handle idx { arg "" } } {
  if {$arg == ""} {
    putidx $idx "[getFriendsList]\r"
    return 0
  }

  if [regexp -nocase {([^ ]+)( (.+))?} $arg matches nick pom val] {
    if {$val == ""} {
      putidx $idx "friendship rating for $nick is [getFriendshipHandle $nick]\r"
    } else {
      setFriendshipHandle $nick $val
      putidx $idx "friendship rating for $nick is now [getFriendshipHandle $nick]\r"
    }
    return 0
  }
}

proc bMotion_plugin_admin_unbindVotes { handle idx arg } {
  putidx $idx "Unbinding vote commands...\r"
  unbind pub - "!innocent" bMotionVoteHandler
  unbind pub - "!guilty" bMotionVoteHandler
  unbind pubm - "!innocent" bMotionVoteHandler
  unbind pubm - "!guilty" bMotionVoteHandler
  putidx $idx "ok\r"
}


proc bMotion_plugin_admin_codesize { handle idx { arg "" } } {
  #get codesize for bMotion
  
  global bMotionRoot bMotionModules bMotionPlugins
  set scriptName "[pwd]/$bMotionRoot/codeSize"

  #check the script is present and executable
  if {![file exists $scriptName]} {
    putidx $idx "bMotion: ERROR: Can't find supporting script $scriptName!"
    return 0
  }

  if {![file executable $scriptName]} {
    putidx $idx "bMotion: ERROR: $scriptName is not executable :("
    return 0
  }

  bMotion_putloglev 2 * "bMotion: codeSize script is $scriptName"
  
  set modules_output [exec $scriptName $bMotionModules]
  set plugins_output [exec $scriptName $bMotionPlugins]
  regexp {([[:digit:]]+) +[[:digit:]]+ +[[:digit:]]+ total} $modules_output matches modules
  regexp {([[:digit:]]+) +[[:digit:]]+ +[[:digit:]]+ total} $plugins_output matches plugins
  regexp {([[:digit:]]+) +[[:digit:]]+ +[[:digit:]]+ .+bMotion\.tcl} [exec wc $bMotionRoot/bMotion.tcl] matches loader

  set total [expr $modules + $plugins + $loader]

  putidx $idx "bMotion: codesize: $loader in stub, $modules in modules, $plugins in plugins, $total in total\r"
  return 0
}

proc bMotion_plugin_admin_rehash { handle idx { arg "" } } {
  global bMotionCache bMotion_testing bMotionRoot

  #check we're not going to die
  catch {
    bMotion_putloglev d * "bMotion: Testing new code..."
    set bMotion_testing 1
    source "$bMotionRoot/bMotion.tcl"
  } msg

  if {$msg != ""} {
    putlog "bMotion: FATAL: Cannot rehash due to error: $msg"
    return 0
  } else {
    bMotion_putloglev d * "bMotion: New code ok, rehashing..."
    set bMotion_testing 0
    rehash
  }
}

proc bMotion_plugin_admin_reload { handle idx { arg "" } } {
  global bMotionCache bMotion_testing bMotionRoot

  #check we're not going to die
  catch {
    bMotion_putloglev d * "bMotion: Testing new code..."
    set bMotion_testing 1
    source "$bMotionRoot/bMotion.tcl"
  } msg

  if {$msg != ""} {
    putlog "bMotion: FATAL: Cannot reload due to error: $msg"
    return 0
  } else {
    bMotion_putloglev d * "bMotion: New code ok, reloading..."
    set bMotion_testing 0
    source "$bMotionRoot/bMotion.tcl"
  }
}

proc bMotion_plugin_admin_settings_clear { handle idx { arg "" } } {
  global bMotion_plugins_settings
  if {![info exists bMotion_plguins_settings]} {
    unset bMotion_plugins_settings
    set bMotion_plugins_settings(dummy,setting,channel,nick) "dummy"
  }
  putidx $idx "Cleared plugins settings array\r"
}
