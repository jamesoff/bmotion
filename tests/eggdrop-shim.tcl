puts "eggdrop shim loading"

set SHIM "\[SHIM\]"

set shim_utimers [list]
set shim_timers [list]

proc shim_check_for_timer { type callback } {
  if {$type == "timer"} {
    foreach entry $::shim_timers {
      if {[lindex $entry 1] == $callback} {
	return 1
      }
    }
    return 0
  }

  if {$type == "utimer"} {
    foreach entry $::shim_utimers {
      if {[lindex $entry 1] == $callback} {
	return 1
      }
    }
    return 0
  }

  return 0
}

proc shim_print { text } {
  puts "\[\033\[01;32mSHIM\033\[0m\] $text"
}

proc shim_print_help { text } {
  puts "\[\033\[01;34mHELP\033\[0m\] $text"
}

proc shim_print_serv { text } {
  puts "\[\033\[01;31mSERV\033\[0m\] $text"
}

proc shim_print_log { text } {
  puts "\[\033\[01;33mLOG\033\[0m\] $text"
}

proc setudef { a b } {
  shim_print "setudef"
}

proc putloglev { level star msg } {
  if {$level == "d"} {
    shim_print_log "($level) $msg"
  }
}

proc putlog { msg } {
  shim_print_log $msg
}

proc bind { args } {
  shim_print "bind $args"
}

proc channels { } {
  return [list "#bmotion"]
}

proc channel { method channel property } {
  shim_print "channel method $method"
  if {$method == "get"} {
    return 1
  }
}

proc rand { max } {
  shim_print "rand"
  return [expr { int(rand() * $max) }]
}

proc utimer { t method } {
  shim_print "utimer: $t $method"
  set ::shim_utimers [lappend ::shim_utimers [list $t $method ]]
}

proc timer { t method } {
  shim_print "timer: $t $method"
  set ::shim_timers [lappend ::shim_timers [list $t $method ]]
}

proc utimers { } {
  shim_print "utimers"
  return [list { 10 doThing }]
}

proc timers { } {
  shim_print "timers"
  return [list { 10 doThing }]
}

proc matchattr { handle flag } {
  shim_print "matchattr"
  return 0
}

proc validuser { nick } {
  shim_print "validuser"
  return 1
}

proc chandname2name { channel } {
  shim_print "chandname2name"
  return $channel
}

proc puthelp { msg } {
  shim_print_help $msg
}

proc putserv { msg } {
  shim_print_serv $msg
}

proc isbotnick { nick } {
  shim_print "isbotnick $nick"
  if { $nick == $::botnick } {
    return 1
  }
  return 0
}

proc ischanban { nick channel } {
  shim_print "ischanban $nick $channel"
  if { $nick == "banned" } {
    return 1
  }
  return 0
}

proc chanlist { channel } {
  shim_print "chanlist $channel"
  return [list "jms" "jamesoff" ]
}

proc nick2hand { nick $channel } {
  shim_print "nick2hand $nick"
  return $nick
}

proc getuser { handle type key } {
  shim_print "getuser $handle $type $key"
  if {$type == "XTRA"} {
    if {$key == "friend"} {
      return 50
    }
  }
}
