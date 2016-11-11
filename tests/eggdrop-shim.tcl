puts "eggdrop shim loading"

set SHIM "\[SHIM\]"

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
  #puts "$::SHIM putlog $msg"
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
}

proc timer { t method } {
  shim_print "timer: $t $method"
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

