###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# %ruser
# %ruser{friend}
# %ruser{friend:owner}
# %ruser{:owner}

proc bMotion_plugin_output_ruser { channel line } {
    bMotion_log "output" "TRACE" "bMotion_plugin_output_ruser $channel $line"

    if [regexp "%ruser(\{(\[a-z\]*)?(:(\[a-z,\]+))?\})?" $line matches allopts filter optstring options] {
        bMotion_log "output" "DEBUG" "found %ruser with filter=$filter and options=$options"

        set ruser [bMotionGetRealName [bMotion_choose_random_user $channel 0 $filter] ""]

        set options_list [split $options ","]
        foreach option $options_list {
            bMotion_log "output" "DEBUG" "working on option $option"
            switch $option {
                "owner" {
                    set ruser [bMotionMakePossessive $ruser]
                }
                "caps" {
                    set ruser [string toupper $ruser]
                }
                default {
                    bMotion_log "output" "ERROR" "unexpected %ruser option $option in $matches"
                }
            }
        }
        regsub $matches $line $ruser line
    }

    return $line
}

bMotion_plugin_add_output "ruser" bMotion_plugin_output_ruser 1 "en" 3
