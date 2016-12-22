# vim: fdm=indent fdn=1
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2011
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, %MOOD
# syntax: %MOOD{type:change}


proc bMotion_plugin_output_MOOD { channel line } {
    bMotion_log "output" "TRACE" "bMotion_plugin_output_MOOD $channel $line"

    if {[regexp {(%MOOD\{([^\}:]+)(:([^\}])+)?\})} $line matches whole_thing type change]} {
        set change [string range $change 1 end]
        bMotion_log "output" "DEBUG" "drifting mood $type by $change from output"
        bMotion_mood_adjust $type $change

        set location [string first $whole_thing $line]
        if {$location == -1} {
            putlog "bMotion: error parsing $whole_thing in $line, unable to remove MOOD element"
            return ""
        }
        set line [string replace $line $location [expr $location + [string length $whole_thing] - 1] ""]
    }

    return $line
}

bMotion_plugin_add_output "MOOD" bMotion_plugin_output_MOOD 1 "en" 5
