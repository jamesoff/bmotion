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

set bMotion_plugin_output_synonym_enabled 0

catch {
	package require sqlite

	bMotion_putloglev 2 * "synonym: sqlite3 loaded"
	sqlite3 bMotion_syn_db $bMotionLocal/bmotion_thes.db
	bMotion_putloglev 2 * "synonym: sqlite db opened"
	set bMotion_plugin_output_synonym_enabled 1
}

bMotion_plugin_add_output "synonym" bMotion_plugin_output_synonym $bMotion_plugin_output_synonym_enabled "en"

proc bMotion_plugin_output_synonym { channel line } {

	global bMotion_plugin_output_synonym_enabled

	if {$bMotion_plugin_output_synonym_enabled == 0} {
		return 0
	}

	global bMotion_syn_db

	set words [split $line " "]

	set newline ""

	foreach word $words {
		if {[rand 100] < 98} {
			append newline "$word "
			continue
		}

		set sql "SELECT syn FROM thes WHERE word = '$word'"
		catch {
			set result [bMotion_syn_db eval $sql]
			if {$result != ""} {
				set result [split $result ","]
			}

			if {[llength $result] > 0} {
				set word [pickRandom $result]
			}
		}
		append newline "$word "
	}

	set line [string trim $newline]

  return $line
}
