source "scripts/bmotion/eggdrop-shim.tcl"

set botnick "NoTopic"

source "scripts/bmotion/bMotion.tcl"

proc q { } {
  bMotion_queue_run
}

proc e { msg } {
  bMotion_event_main jms jms jms #bmotion $msg
}

puts "===== bMotion test environment"
puts "      q: run event queue"
puts "      e <text>: inject channel event"
puts ""
