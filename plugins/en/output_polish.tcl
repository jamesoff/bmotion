#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_output "polish" bMotion_plugin_output_polish 0 "en" 11


proc bMotion_plugin_output_polish { channel line } {
    set line [string trim $line]

    if {[string range $line 0 0] == "/"} {
        return $line
    }

    set newline ""
    set words [split $line " "]

    foreach word $words {
        #not for one letter words
        if {[string length $word] == 1} {
            append newline "$word "
            continue
        }

        # words ending with "s" get "with a z" added
        if {[regexp -nocase {([sS])([,.?!]?)$} $word m a b]} {
            if {$a == 's'} {
                append newline "$word with a z$b "
            } else {
                append newline "$word WITH A Z$b "
            }
            continue
        }
        append newline "$word "
    }
    return $newline
}
