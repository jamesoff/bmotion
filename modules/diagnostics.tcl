# bMotion - Diagnostics
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2008
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

bMotion_log_add_category "diagnostics"

# make sure we only have one instance of each timer
proc bMotion_diagnostic_timers { } {
	bMotion_log "diagnostics" "TRACE" "running level 4 diagnostic on timers"
	set alltimers [timers]
	set seentimers [list]
	foreach t $alltimers {
		bMotion_log "diagnostics" "DEBUG" "checking timer $t"
		set t_function [lindex $t 1]
		set t_name [lindex $t 2]
		set t_function [string tolower $t_function]
		if {[lsearch $seentimers $t_function] >= 0} {
			bMotion_log "diagnostics" "DEBUG" "bMotion: A level 4 diagnostic has found a duplicate timer $t_name for $t_function ... removing (this is not an error)"
			#remove timer
			killtimer $t_name
		} else {
			#add to seen list
			lappend seentimers $t_function
		}
	}
}


# make sure we have only one instance of each utimer
proc bMotion_diagnostic_utimers { } {
	bMotion_log "diagnostics" "TRACE" "running level 4 diagnostic on utimers"
	set alltimers [utimers]
	set seentimers [list]
	foreach t $alltimers {
		bMotion_log "diagnostics" "DEBUG" "checking timer $t"
		set t_function [lindex $t 1]
		set t_name [lindex $t 2]
		set t_function [string tolower $t_function]
		if {[lsearch $seentimers $t_function] >= 0} {
			bMotion_log "diagnostics" "DEBUG" "bMotion: A level 4 diagnostic has found a duplicate utimer $t_name for $t_function ... removing (this is not an error)"
			#remove timer
			killutimer $t_name
		} else {
			#add to seen list
			lappend seentimers $t_function
		}
	}
}


# make sure binds we shouldn't have any more are gone
proc bMotion_diagnostic_binds { } {
	bMotion_log "diagnostics" "TRACE" "running level 3 diagnostic on binds"

	set time_binds [binds time]
	foreach b $time_binds {
		if {[lindex $b 4] == "bMotion_flood_tick"} {
			bMotion_log "diagnostics" "INFO" "Found an old bind for bMotion_flood_tick, removing..."
			unbind time [lindex $b 1] [lindex $b 2] bMotion_flood_tick
		}
	}
}


# check some plugins loaded
proc bMotion_diagnostic_plugins { } {
	bMotion_log "diagnostics" "TRACE" "bMotion_diagnostic_plugins"
	foreach t {simple complex output action_simple action_complex irc_event management} {
		set arrayName "bMotion_plugins_$t"
		upvar #0 $arrayName cheese
		if {[llength [array names cheese]] == 0} {
			bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: No $t plugins loaded, something is wrong!"
		}
	}
}


# check needed settings are defined
proc bMotion_diagnostic_settings { } {
	global bMotionInfo bMotionSettings

	set errors 0

	if {![info exists bMotionInfo(gender)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: Gender not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionInfo(orientation)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: Orientation not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(kinky)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: kinky not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(friendly)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: friendly not defined, check settings file!"
		set errors 1
	} else {
		if {![string is integer $bMotionSettings(friendly)]} {
			bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: friendly setting is supposed to be a number 0-2!"
			set error 1
		}
	}

	if {![info exists bMotionSettings(melMode)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: melMode not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(needI)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: needI not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionInfo(balefire)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: balefire not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(useAway)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: useAway not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(botnicks)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: botnicks not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(noAwayFor)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: noAwayFor not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(typos)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: typos not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(colloq)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: colloq not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(homophone)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: homophone not defined, check settings file!"
		set errors 1
	}


	if {![info exists bMotionInfo(minRandomDelay)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: minRandomDelay not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionInfo(maxRandomDelay)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: maxRandomDelay not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionInfo(maxIdleGap)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: maxIdleGap not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionInfo(brigDelay)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: brigDelay not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(silenceTime)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: silenceTime not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(languages)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: languages not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(typingSpeed)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: typingSpeed not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(disableFloodChecks)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: disableFloodChecks not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(abstractMaxAge)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: abstractMaxAge not defined, check settings file!"
		set errors 1
	}

	if {![info exists bMotionSettings(abstractMaxNumber)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: abstractMaxNumber not defined, check settings file!"
		set errors 1
	}
	if {![info exists bMotionSettings(factsMaxItems)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: factsMaxItems not defined, check settings file!"
		set errors 1
	}
	if {![info exists bMotionSettings(factsMaxFacts)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: factsMaxFacts not defined, check settings file!"
		set errors 1
	}
	if {![info exists bMotionSettings(bitlbee)]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics: bitlbee not defined, check settings file!"
		set errors 1
	}

	if {$errors == 1} {
		bMotion_log "diagnostics" "ERROR" "bMotion: ### ONE OR MORE SETTINGS IS MISSING OR BROKEN"
		bMotion_log "diagnostics" "ERROR" "bMotion: ### It's likely that your bot will be broken!"
	}
}


# Check to see if the user has added IRL and GENDER to their userinfo stuff
proc bMotion_diagnostic_userinfo { } {
	global userinfo-fields
	
	if {![info exists userinfo-fields]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics indicate you haven't loaded the userinfo TCL script"
		bMotion_log "diagnostics" "ERROR" "         this is not required, but is strongly recommended"
		return 
	}

	if {![string match "*GENDER*" ${userinfo-fields}]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics indicate you haven't added the GENDER field to the"
		bMotion_log "diagnostics" "ERROR" "         userinfo.tcl script. This is not required, but is recommended"
		return
	}

	if {![string match "*IRL*" ${userinfo-fields}]} {
		bMotion_log "diagnostics" "ERROR" "bMotion: diagnostics indicate you haven't added the IRL field to the"
		bMotion_log "diagnostics" "ERROR" "         userinfo.tcl script. This is not required, but is recommended"
		return
	}
	return
}


proc bMotion_diagnostic_eggdropsettings { } {

	global answer-ctcp

	if {${answer-ctcp} == 0} {
		putlog "bMotion: you have 'answer-ctcp' set to 0 in your eggdrop config."
		putlog "         This bot will not be able to respond to actions (/me)!"
	}
}


# Check if bitlbee mode is enabled, but the bot doesn't know about #bitlbee/&bitlbee
proc bMotion_diagnostic_bitlbee { } {
	global bMotionSettings
	if {!$bMotionSettings(bitlbee)} {
		return
	}

	set found_bitlbee 0
	foreach channel [channels] {
		if [string match -nocase "*bitlbee" $channel] {
			set found_bitlbee 1
			break
		}
	}

	if {!$found_bitlbee} {
		bMotion_log "diagnostics" "ERROR" "bMotion: bitlbee mode is enabled, but I don't seem to be"
		bMotion_log "diagnostics" "ERROR" "         configured to be in a bitlbee channel... maybe you"
		bMotion_log "diagnostics" "ERROR" "         should turn bitlbee mode off else things will go weird!"
	}
}


# Try to build every abstract we can and make sure it parses ok
# This is not run automatically!
# This is run as an admin plugin, so it tries to output to the admin stuff
proc bMotion_diagnostic_parsing { } {
	bMotion_putadmin "Counting abstracts..."
	set all_abstracts [bMotion_abstract_get_names]
	set all_abstracts_size [llength $all_abstracts]
	bMotion_putadmin "Found $all_abstracts_size abstracts"

	set broken [list]
	set errors 0
	set count_abstract 0
	set count_lines 0
	set i 0

	foreach abstract $all_abstracts {
		incr i
		if {[expr $i % 10] == 0} {
			bMotion_putadmin "Processing abstract $i: $abstract..."
		}
		set abstract_contents [bMotion_abstract_all $abstract]
		bMotion_putloglev d * "Processing [llength $abstract_contents] items for abstract $abstract"
		incr count_abstract
		foreach content $abstract_contents {
			incr count_lines
			set line ""
			set fail ""
			catch {
				set line [bMotion_process_macros "" $content]
				set line [bMotionDoInterpolation $line "JamesOff" "moretext" "#diagnostics"]
				# bit of a hack!
				set line [bMotion_plugin_output_preprocess "#diagnostics" $line]
			} 
			if {($line == "") || [regexp {%(?!(SETTING|ruser|r?bot|BOT|percent|channel))[^%2\| ]} $line matches moo]} {
				incr errors
				lappend broken "$abstract:$content\r\n  -> $line"
			}
		}
	}

	bMotion_putadmin "Finished."
	bMotion_putadmin "$errors errors found in $count_lines lines in $count_abstract abstracts."
	foreach line $broken {
		bMotion_putadmin $line
	}
}


proc bMotion_diagnostic_auto { min hr a b c } {
	bMotion_log "diagnostics" "TRACE" "bMotion_diagnostic_auto"
	bMotion_log "diagnostics" "INFO" "bMotion: running level 4 self-diagnostic"
	bMotion_diagnostic_timers
	bMotion_diagnostic_utimers
}


if {$bMotion_testing == 0} {
	bMotion_log "diagnostics" "TRACE" "Running a level 5 self-diagnostic..."

	bMotion_diagnostic_plugins
	bMotion_diagnostic_settings
	bMotion_diagnostic_userinfo
	bMotion_diagnostic_bitlbee
	bMotion_diagnostic_binds
	bMotion_diagnostic_eggdropsettings

	bMotion_log "diagnostics" "INFO" "Diagnostics complete."
}

bind time - "30 * * * *" bMotion_diagnostic_auto
