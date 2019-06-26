package require json::write
package require json

source "tests/eggdrop-shim.tcl"

set botnick "NoTopic"
set bMotionRoot "."

rename puthelp ""

set output_values [list]

proc puthelp { text } {
    global output_values
    puts "puthelp: $text"
    set bits [split $text ":"]
    set bits [lreplace $bits 0 0]
    set text [join $bits ":"]
    lappend output_values $text
}

source "bMotion.tcl"

set output_values [list]

proc lambda_handler { context event } {
    global output_values
    set body [::json::json2dict [dict get $event body]]
    set text [dict get $body input]
    if {[string range $text 0 0] == "/"} {
        bMotion_event_action jms jms jms "#bmotion" keyword [string range $text 1 end]
    } else {
        bMotion_event_main jms jms jms #bmotion $text 
    }
    while {[bMotion_queue_size] > 0} {
        bMotion_queue_run
    }
    puts $output_values
    set output_value [join $output_values "\n"]
    set retval [::json::write object \
        "statusCode" "200" \
        "body" [::json::write string [::json::write object "output" [::json::write::string $output_value]]] \
    ]
    set output_values [list]
    return $retval
}