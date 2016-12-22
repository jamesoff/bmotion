#
#
# vim: fdm=indent fdn=1
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, simple things

proc bMotion_plugin_output_preprocess { channel line } {
	global botnick

    bMotion_log "output" "TRACE" "bMotion_plugin_output_preprocess $channel $line"

	set line [string map " %pronoun [getPronoun] %himherself [getPronoun] %me $botnick %colen [bMotionGetColenChars] %hishers [getHisHers] %heshe [getHeShe] %hisher [getHisHer] %daytime [bMotion_get_daytime] " $line]
	regsub -all "%space" $line " " line

	return $line
}

bMotion_plugin_add_output "preprocess" bMotion_plugin_output_preprocess 1 "en" 13
