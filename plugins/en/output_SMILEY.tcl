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


# built-in processing, %SMILEY
# syntax: %SMILEY{type}
#         %VAR{type:options}
# options: a comma-separated list of options
#          none yet



proc bMotion_plugin_output_SMILEY { channel line } {
    bMotion_log "output" "TRACE" "bMotion_plugin_output_SMILEY $channel $line"

	set smiley_type [bMotion_setting_get "smileytype"]
	set smiley_nose_type [bMotion_setting_get "smileynosetype"]

	if {[regexp {(%SMILEY?\{([^\}:]+)(:([^\}])+)?\})} $line matches whole_thing type options]} {
        bMotion_log "output" "TRACE" "output_smiley: type=$type options=$options"

		set smiley [bMotion_get_smiley $type]
		if {$smiley == ""} {
            bMotion_log "output" "WARN" "Unable to get smiley for type $type"
		}

		set location [string first $whole_thing $line]
		if {$location == -1} {
			bMotion_log "output" "ERROR" "error parsing $whole_thing in $line, unable to insert $smiley"
			return ""
		}

		set line [string replace $line $location [expr $location + [string length $whole_thing] - 1] $smiley]
	}

	return $line
}

bMotion_plugin_add_output "SMILEY" bMotion_plugin_output_SMILEY 1 "en" 5
bMotion_plugin_add_output "SMILE" bMotion_plugin_output_SMILEY 1 "en" 5
