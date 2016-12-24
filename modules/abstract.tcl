# bMotion - Abstract Handling
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

# Summary of new abstract system design:
#
# Abstracts are getting out of control... the amount of information bMotion tracks can get silly
# with the whole learning arrangement. The idea behind the new system is that abstracts are stored
# on disk, and loaded into memory when needed, at which point they're loaded into memory.
#
# At some point they're unloaded (i.e. deallocated) out of memory to free up space. This will
# probably be done by deallocating them 5 mins after their last use.
#
# This has important implications for bMotion. No longer will abstracts be stored as global-scope
# lists, but in some name-indexed array. Code that directly fetches abstracts (rather than using
# %VAR{}) will fail.
#
# Due to the way the caching will work, abstracts should be fetched through an interface rather than
# directly indexing the array. This interface also means the way abstracts are stored internally can
# be changed later on without affecting the operation of the rest of bMotion.
#
# Variables:
#   bMotion_abstract_contents: a name-indexed array containing the lists of abstracts
#   bMotion_abstract_timestamps: a name-indexed array containing the last access time of an abstract
#                                0 means not cached
#
# Functions:
#   bMotion_abstract_register(abstract): register that an abstract should be tracked. A file for it
#                                        if created on disk if needed; if the file exists then the
#                                        contents are loaded
#   bMotion_abstract_add(abstract, contents): add an abstract to a list. The change is immediately
#                                             written to disk
#   bMotion_abstract_get(abstract): return a random element from the list. The list is transparnetly
#                                   loaded from disk if needed
#   bMotion_abstract_gc(): the "garbage collector": unsets any abstracts not used recently
#   bMotion_abstract_all(abstract): return the list of all elements from an abstract
#   bMotion_abstract_delete(abstract, index): delete from an abstract. The change is immediately
#                                             written to disk
#   bMotion_abstract_load(abstract): cache the abstract list in memory from disk
#   bMotion_abstract_save(abstract): saves the cached version to disk
#
# Admin plugin to be loaded (but not from this module):
#   !bmadmin abstract (add|list|view|del(ete)?|cache|gc) ...
#
# NOTE: This module should be loaded before plugins as they will need it to register abstracts
#
# The abstracts will be stored in ./abstracts/<language>/<abstract name>.txt in the bMotion directory. The
# fileformat is simply one per line.

bMotion_log_add_category "abstracts"

# default = mixin own gender
# reverse = mixin opposite gender
# none = don't mixin at all
set BMOTION_MIXIN_DEFAULT 0
set BMOTION_MIXIN_REVERSE 1
set BMOTION_MIXIN_NONE 2
set BMOTION_MIXIN_BOTH 3
set BMOTION_MIXIN_FEMALE 4
set BMOTION_MIXIN_MALE 5


if { [bMotion_setting_get "abstractMaxAge"] != "" } {
	set bMotion_abstract_max_age [bMotion_setting_get "abstractMaxAge"]
} else {
	set bMotion_abstract_max_age 300
}


if { [bMotion_setting_get "abstractMaxNumber"] != "" } {
	set bMotion_abstract_max_number [bMotion_setting_get "abstractMaxNumber"]
} else {
	set bMotion_abstract_max_number 600
}


# initialise the arrays
if {![info exists bMotion_abstract_contents]} {
	array set bMotion_abstract_contents {}
	array set bMotion_abstract_languages {}
	array set bMotion_abstract_timestamps {}
	set bMotion_abstract_ondisk [list]
	array set bMotion_abstract_last_get {}
	array set bMotion_abstract_filters {}
}

set bMotion_abstract_dir "$bMotionLocal/abstracts/$bMotionInfo(language)"


proc bMotion_abstract_gc { { force 0 } } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_gc"

	if [bMotion_redis_available] {
		bMotion_log "abstracts" "DEBUG" "Not garbage collecting abstracts as we're using redis"
		return
	}

	global bMotion_abstract_contents bMotion_abstract_timestamps
	global bMotion_abstract_max_age bMotion_abstract_ondisk
	global bMotionInfo bMotion_abstract_languages
	set lang $bMotionInfo(language)

	bMotion_log "abstracts" "DEBUG" "Garbage collecting abstracts"

	set abstracts [array names bMotion_abstract_contents]
	if {$force == 1} {
		set limit [expr [clock seconds] + 1]
	} else {
		set limit [expr [clock seconds] - $bMotion_abstract_max_age]
	}

	set expiredList ""
	set expiredCount 0

	foreach abstract $abstracts {
		if {($bMotion_abstract_timestamps($abstract) < $limit) && ($bMotion_abstract_timestamps($abstract) > 0) || $bMotion_abstract_languages($abstract) != $lang } {
			append expiredList "$abstract "
			incr expiredCount
			unset bMotion_abstract_contents($abstract)
			unset bMotion_abstract_languages($abstract)
			set bMotion_abstract_timestamps($abstract) 0
			lappend bMotion_abstract_ondisk $abstract
		}
	}

	if {$expiredList != ""} {
		bMotion_log "abstracts" "INFO" "gc: expired $expiredCount abstracts: $expiredList"
	}
}


proc bMotion_abstract_register { abstract { stuff "" } } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_register ($abstract)"
	if [bMotion_redis_available] {
		if {$stuff != ""} {
			bMotion_abstract_batchadd $abstract $stuff
		}
		return
	}

	global bMotion_abstract_contents bMotion_abstract_timestamps
	global bMotionModules bMotion_testing bMotion_loading
	global bMotionInfo bMotion_abstract_languages bMotion_abstract_dir
	global bMotion_abstract_last_get bMotion_abstract_filters

	#set timestamp to now
	set bMotion_abstract_timestamps($abstract) [clock seconds]
	set lang $bMotionInfo(language)
	set bMotion_abstract_last_get($abstract) ""
	set bMotion_abstract_filters($abstract) ""

	#load any existing abstracts
	if [file exists "$bMotion_abstract_dir/${abstract}.txt"] {
		bMotion_abstract_load $abstract 
	} else {
		# check that the language directory exists while we're at it
		if { ![file exists $bMotion_abstract_dir] } {
			file mkdir $bMotion_abstract_dir
		}
		#file doesn't exist - create an empty one
		#create blank array for it
		set bMotion_abstract_contents($abstract) [list]
		set bMotion_abstract_languages($abstract) "$lang"
		bMotion_log "abstracts" "DEBUG" "Creating new abstract file for $abstract"
		set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "w"]
		puts $fileHandle " "
	}

	if {[info exists fileHandle]} {
		close $fileHandle
	}

	if {$stuff != ""} {
		# batch-add at the same time
		bMotion_log "abstracts" "TRACE" "Batchadding during registration for $abstract"
		bMotion_abstract_batchadd $abstract $stuff
	}
}


proc bMotion_abstract_load { abstract } { 
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_load ($abstract)" 

	if [bMotion_redis_available] {
		bMotion_log "abstracts" "DEBUG" "Not loading abstract $abstract as we're using redis"
		return
	}

	global bMotion_abstract_contents bMotion_abstract_timestamps
	global bMotionModules bMotion_abstract_ondisk
	global bMotion_loading bMotion_testing
	global bMotionInfo bMotion_abstract_languages
	global bMotion_abstract_dir
	set lang $bMotionInfo(language)

	bMotion_log "abstracts" "INFO" "Attempting to load $bMotion_abstract_dir/${abstract}.txt"

	if {![file exists "$bMotion_abstract_dir/${abstract}.txt"]} {
		return
	}

	#create blank array for it
	set bMotion_abstract_contents($abstract) [list]
	set bMotion_abstract_languages($abstract) "$lang"

	#set timestamp to now
	set bMotion_abstract_timestamps($abstract) [clock seconds]

	if {$bMotion_testing} {
		return 0
	}

	#remove from ondisk list
	set index [lsearch -exact $bMotion_abstract_ondisk $abstract]
	set bMotion_abstract_ondisk [lreplace $bMotion_abstract_ondisk $index $index]

	set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "r"]
	set line [gets $fileHandle]
	set needReSave 0
	set count 0

	while {![eof $fileHandle]} {
		set line [string trim $line]
		if {$line != ""} {
			lappend bMotion_abstract_contents($abstract) $line
			incr count
		}
		set line [gets $fileHandle]
	}

	#optimise
	set bMotion_abstract_contents($abstract) [lsort -unique $bMotion_abstract_contents($abstract)]
	set newcount [llength $bMotion_abstract_contents($abstract)]
	if {$newcount < $count} {
		bMotion_log "abstracts" "DEBUG" "Shrunk abstract $abstract by [expr $count - $newcount] items by de-duping"
		set needReSave 1
	}

	if {$abstract == "sillyThings"} {
		bMotion_log "abstracts" "DEBUG" "Performing 'sillyThings' filtering"
		set newlist [list]
		foreach element $bMotion_abstract_contents($abstract) {
			if {[bMotion_filter_sillyThings $element] == 1} {
				lappend newlist $element
			}
		}
		set bMotion_abstract_contents($abstract) $newlist
		set needReSave 1
	}

	if {[info exists fileHandle]} {
		close $fileHandle
	}

	if {$needReSave} {
		bMotion_abstract_save $abstract
	}

	bMotion_log "abstracts" "DEBUG" "Abstract $abstract loaded, checking for filter"
	bMotion_abstract_apply_filter $abstract
}


proc bMotion_abstract_add { abstract text {save 1} } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_add ($abstract, $text, $save)"
	global bMotionInfo
	set lang $bMotionInfo(language)

	if [bMotion_redis_available] {
		set result [bMotion_redis_cmd sadd abstract:$lang:$abstract $text]
		bMotion_log "abstracts" "DEBUG" "Result of adding $text to abstract $abstract: $result"
		return
	}

	global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age
	global bMotionModules bMotionInfo
	global bMotion_abstract_dir

	bMotion_log "abstracts" "DEBUG" "Adding '$text' to abstract '$abstract'"

	if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
		bMotion_log "abstracts" "DEBUG" "updating abstracts '$abstract' on disk"
		if {$save} {
			set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "a+"]
			puts $fileHandle $text
			close $fileHandle
		}
		return
	}

	if {[lsearch -exact $bMotion_abstract_contents($abstract) $text] == -1} {
		lappend bMotion_abstract_contents($abstract) $text
		if {$save} {
			bMotion_log "abstracts" "DEBUG" "updating abstracts '$abstract' on disk and in memory"
			set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "a+"]
			puts $fileHandle $text
			close $fileHandle
		}
	}
}


proc bMotion_abstract_save { abstract } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_save"

	if [bMotion_redis_available] {
		bMotion_log "abstracts" "DEBUG" "Not saving abstract $abstract as we're using redis"
		return
	}

	global bMotion_abstract_contents
	global bMotionModules bMotion_testing bMotion_loading
	global bMotion_abstract_max_number bMotionInfo bMotion_abstract_languages

	global bMotion_abstract_dir
	set lang $bMotionInfo(language)

	if {$lang != $bMotion_abstract_languages($abstract) } {
		bMotion_log "abstracts" "DEBUG" "Did not save '$abstract' to disk (wrong language)"
		return 0
	}

	set tidy 0
	set count 0
	set drop_count 0

	#don't save if we're starting up else we'll lose saved stuff
	if {$bMotion_testing} {
		return 0
	}

	bMotion_log "abstracts" "DEBUG" "Saving abstracts '$abstract' to disk"

	set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "w"]
	set number [llength $bMotion_abstract_contents($abstract)]
	if {$number > $bMotion_abstract_max_number} {
		bMotion_log "abstracts" "INFO" "Abstract $abstract has too many elements ($number > $bMotion_abstract_max_number), tidying up"
		set tidy 1
	}
	foreach a $bMotion_abstract_contents($abstract) {
		if {$tidy} {
			if {[rand 100] < 10} {
				bMotion_log "abstracts" "DEBUG" "Dropped '$a' from abstract $abstract"
				incr drop_count
				continue
			}
		}
		puts $fileHandle $a
		incr count
	}
	if {$tidy} {
		bMotion_log "abstracts" "INFO" "Abstract $abstract now has $count elements ($drop_count fewer)"
	}
	close $fileHandle
	bMotion_log "abstracts" "DEBUG" "Saved abstract $abstract to disk"
}


proc bMotion_abstract_all { abstract } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_all ($abstract)"
	global bMotionInfo
	set lang $bMotionInfo(language)

	if [bMotion_redis_available] {
		return [bMotion_redis_cmd smembers abstract:$lang:$abstract]
	}

	global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age

	if [info exists bMotion_abstract_timestamps($abstract)] {
		if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
			bMotion_abstract_load $abstract
		}

		return $bMotion_abstract_contents($abstract)
	} else {
		#abstract doesn't exist
		bMotion_log "abstracts" "WARN" "bMotion_abstract_all: couldn't find abstract '$abstract' in new system"
		catch {
			global $abstract
			set var [subst $$abstract]

			return $var
		}
		bMotion_log "abstracts" "WARN" "bMotion_abstract_all: $abstract doesn't exist as a global variable either :("
		return ""
	}

}


# look to see if an abstract contains an item (warning: could be slow)
proc bMotion_abstract_contains { abstract item } {
	bMotion_log "abstracts" "TRACE" "abstract: bMotion_abstract_contains $abstract $item"

	global bMotionInfo
	set lang $bMotionInfo(language)

	if [bMotion_redis_available] {
		return [bMotion_redis_cmd sismember abstract:$lang:$abstract $item]
	}

	set contents [bMotion_abstract_all $abstract]

	if {[llength $contents] == 0} {
		return 0
	}

	set location [lsearch $contents $item]
	if {$location > -1} {
		return 1
	} else {
		return 0
	}
}


proc bMotion_abstract_exists { abstract } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_exists ($abstract)"
	global bMotionInfo
	set lang $bMotionInfo(language)

	if [bMotion_redis_available] {
		return [bMotion_redis_cmd exists abstract:$lang:$abstract]
	}

	global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age bMotion_abstract_last_get

	bMotion_log "abstracts" "DEBUG" "checking for existence of abstract $abstract"

	if {![info exists bMotion_abstract_timestamps($abstract)]} {
		return 0
	}
	return 1
}


proc bMotion_abstract_get { abstract { mixin_type 0 } } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_get ($abstract $mixin_type)"

	global bMotionInfo
	set lang $bMotionInfo(language)

	if [bMotion_redis_available] {
		# For now, we union these into another key temporarily
		# Possibly we should run this logic server-side in Lua?
		set temp_abstract "cabstract:$lang:$abstract:$mixin_type"
		bMotion_log "abstracts" "DEBUG" "temporary compiled abstract will be $temp_abstract"

		set gender $bMotionInfo(gender)

		if {[bMotion_redis_cmd keys $temp_abstract] != $temp_abstract} {
			bMotion_log "abstracts" "DEBUG" "compiled abstract $temp_abstract does not exist, creating"

			switch $mixin_type {
				0 {
					# Mix standard abstract with gender specific one (if available)
					bMotion_redis_cmd sunionstore $temp_abstract abstract:$lang:$abstract abstract:$lang:${abstract}_$gender
				}
				1 {
					# Mix standard abstract with gender-flipped one (if available)
					if {$gender == "male"} {
						set gender "female"
					} else {
						set gender "male"
					}
					bMotion_redis_cmd sunionstore $temp_abstract abstract:$lang:$abstract abstract:$lang:${abstract}_$gender
				}
				2 {
					# Do nothing(?)
					bMotion_redis_cmd sunionstore $temp_abstract abstract:$lang:$abstract
				}
				3 {
					# Mix in both
					bMotion_redis_cmd sunionstore $temp_abstract abstract:$lang:$abstract abstract:$lang:${abstract}_male abstract:$lang:${abstract}_female
				}
				4 {
					# Mix in male
					bMotion_redis_cmd sunionstore $temp_abstract abstract:$lang:$abstract abstract:$lang:${abstract}_male 
				}
				5 {
					# Mix in female
					bMotion_redis_cmd sunionstore $temp_abstract abstract:$lang:$abstract abstract:$lang:${abstract}_female
				}
			}

			# Set the temporary abstract to expire in 5 mins 
			bMotion_redis_cmd expire $temp_abstract 900
		} else {
			bMotion_log "abstracts" "DEBUG" "compiled abstract $temp_abstract already exists"
		}

		set count 0
		global bMotion_abstract_get
		set retval [bMotion_redis_cmd srandmember $temp_abstract]
		set last [bMotion_redis_cmd get $abstract:last]
		while {$retval == $last} {
			bMotion_log "abstracts" "INFO" "fetched repeat value for abstract $abstract, trying again"
			bMotion_log "abstracts" "INFO" "this: $retval ... last: $last"
			set retval [bMotion_redis_cmd srandmember $temp_abstract]
			incr count
			if {$count > 5} {
				bMotion_log "abstracts" "WARN" "trying too hard to find non-dupe for abstract $abstract, giving up and using $retval"
				break
			}
		}
		bMotion_redis_cmd set abstract:$lang:$abstract:last $retval
		return $retval
	}


	global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age bMotion_abstract_last_get bMotionInfo

	bMotion_log "abstracts" "DEBUG" "getting abstract $abstract"

	if {![info exists bMotion_abstract_timestamps($abstract)]} {
		return ""
	}

	if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
		bMotion_log "abstracts" "DEBUG" "abstract $abstract has been unloaded, reloading..."
		bMotion_abstract_load $abstract
	}

	set bMotion_abstract_timestamps($abstract) [clock seconds]

	if {![info exists bMotion_abstract_last_get($abstract)]} {
		set bMotion_abstract_last_get($abstract) ""
	}

	# look for male and female versions, and merge in if needed
	set final_version [bMotion_abstract_all $abstract]
    set gender [bMotion_setting_get "gender"]
	switch $mixin_type {
		0 {
			if [bMotion_abstract_exists "${abstract}_$gender"] {
				# mix-in the gender one with the vanilla one
				bMotion_log "abstracts" "DEBUG" "mixing in $gender version of $abstract"
				set final_version [concat $final_version [bMotion_abstract_all "${abstract}_$gender"]]
			} else {
				set final_version [bMotion_abstract_all $abstract]
			}
		}
		1 {
			if {$gender == "male"} {
				set gender "female"
			} else {
				set gender "male"
			}
			if [bMotion_abstract_exists "${abstract}_$gender"] {
				# mix-in the gender one with the vanilla one
				bMotion_log "abstracts" "DEBUG" "mixing in $gender version of $abstract"
				set final_version [concat $final_version [bMotion_abstract_all "${abstract}_$gender"]]
			} else {
				set final_version [bMotion_abstract_all $abstract]
			}
		}
		2 {
			# noop, we did it already before the switch
		}
		3 {
			if [bMotion_abstract_exists "${abstract}_male"] {
				bMotion_log "abstracts" "DEBUG" "mixing in male version of $abstract"
				set final_version [concat $final_version [bMotion_abstract_all "${abstract}_male"]]
			}
			if [bMotion_abstract_exists "${abstract}_female"] {
				bMotion_log "abstracts" "DEBUG" "mixing in female version of $abstract"
				set final_version [concat $final_version [bMotion_abstract_all "${abstract}_female"]]
			}
		}
		5 {
			if [bMotion_abstract_exists "${abstract}_male"] {
				bMotion_log "abstracts" "DEBUG" "mixing in male version of $abstract"
				set final_version [concat $final_version [bMotion_abstract_all "${abstract}_male"]]
			}
		}
		4 {
			if [bMotion_abstract_exists "${abstract}_female"] {
				bMotion_log "abstracts" "DEBUG" "mixing in female version of $abstract"
				set final_version [concat $final_version [bMotion_abstract_all "${abstract}_female"]]
			}
		}

		default {
			bMotion_log "abstracts" "ERROR" "unknown mixin type $mixin_type for abstract $abstract"
		}
	}

	bMotion_log "abstracts" "DEBUG" "final_version abstract name is $final_version"
	if {[llength $final_version] == 0} {
		bMotion_log "abstracts" "INFO" "abstract '$abstract' is empty!"
		return ""
	} else {
		set retval [lindex $final_version [rand [llength $final_version]]]
		if {[llength $final_version] > 1} {
			set count 0
			while {$retval == $bMotion_abstract_last_get($abstract)} {
				bMotion_log "abstracts" "INFO" "fetched repeat value for abstract $abstract, trying again"
				bMotion_log "abstracts" "INFO" "this: $retval ... last: $bMotion_abstract_last_get($abstract)"
				set retval [lindex $final_version [rand [llength $final_version]]]
				incr count
				if {$count > 5} {
					bMotion_log "abstracts" "WARN" "trying too hard to find non-dupe for abstract $abstract, giving up and using $retval"
					break
				}
			}
		}
	}

	set bMotion_abstract_last_get($abstract) $retval
	bMotion_log "abstracts" "TRACE" "successfully got '$retval' from '$abstract'"
	return $retval
}


proc bMotion_abstract_delete { abstract index } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_delete ($abstract, $index)"

	if [bMotion_redis_available] {
		bMotion_log "abstracts" "WARN" "bMotion: cannot use bMotion_abstract_delete with redis"
		return
	}

	global bMotion_abstract_contents

	set bMotion_abstract_contents($abstract) [lreplace $bMotion_abstract_contents($abstract) $index $index]
	bMotion_abstract_save $abstract
}


proc bMotion_abstract_auto_gc { min hr a b c } {
	bMotion_abstract_gc
}


proc bMotion_abstract_batchadd { abstract stuff } {
	bMotion_log "abstracts" "DEBUG" "batch-adding to $abstract"
	foreach i $stuff {
		bMotion_abstract_add $abstract $i 0
	}
	bMotion_abstract_save $abstract
}


# flush all of the abstracts to disk
# this was created for changing languages on the fly. If you're using this
# for some other reason, then you might want to be sure.
proc bMotion_abstract_flush { } {
	if [bMotion_redis_available] {
		bMotion_log "abstracts" "DEBUG" "not flushing abstracts as we're using redis"
		return
	}

	global bMotionInfo bMotion_abstract_contents
	global bMotion_abstract_languages
	set lang $bMotionInfo(language)
	set abstracts [array names bMotion_abstract_contents]
	foreach abstract $abstracts {
		set storedLang $bMotion_abstract_languages($abstract)
		if { $storedLang == $lang } {
			bMotion_abstract_save $abstract
			unset bMotion_abstract_contents($abstract)
			unset bMotion_abstract_languages($abstract)
		}
	}
	array set bMotion_abstract_contents {}
	array set bMotion_abstract_languages {}
	array set bMotion_abstract_timestamps {}
	set bMotion_abstract_ondisk [list]
}


# this loads language abstracts for the current language in bMotionInfo
proc bMotion_abstract_revive_language { } {
	global bMotionSettings bMotionInfo bMotionModules
	global bMotion_abstract_contents bMotionLocal bMotion_abstract_filters

	set lang $bMotionInfo(language)

	bMotion_log "abstracts" "INFO" "bMotion: reviving language ($lang) abstracts"
	set languages [split $bMotionSettings(languages) ","]
	# just check if it's ok to use this language
	set ok 0
	foreach language $languages {
		if { $lang == $language } {
			set ok 1
		}
	}
	if { $ok != 1 } {
		bMotion_log "abstracts" "ERROR" "bMotion: language not found, cannot revive"
		return -1
	}
	# if the default abstracts exists, use it first
	if { [file exists "$bMotionModules/abstracts/$lang/abstracts.tcl"] } {
		bMotion_log "abstracts" "INFO" "loading system abstracts for lang $lang"
		catch {
			source "$bMotionModules/abstracts/$lang/abstracts.tcl"
		} err
		if {($err != "") && ($err != "0")} {
			bMotion_log "abstracts" "ERROR" "Error from loading abstracts: $err"
		}
	} else {
		bMotion_log "abstracts" "WARN" "bMotion: language default abstracts not found"
	}
	# then we need to load any others
	#TODO: should this be bMotionLocal not bMotionModules?
	set files [glob -nocomplain "$bMotionModules/abstracts/$lang/*.txt"]
	if { [llength $files] > 0} {
		foreach f $files {
			set pos [expr [string last "/" $f] + 1]
			set dot [expr [string last ".txt" $f] - 1]
			set abstract [string range $f $pos $dot]
			set len 0
			catch { set len [llength $bMotion_abstract_contents($abstract)] } val
			if { $val != "$len" } {
				bMotion_abstract_load $abstract
			}
		}
	}

	# load the local abstracts
	bMotion_log "abstracts" "INFO" "looking for local abstracts..."
	if [file exists "$bMotionLocal/abstracts/$lang/abstracts.tcl"] {
		bMotion_log "abstracts" "DEBUG" "found local abstracts.tcl for $lang, loading"
		catch {
			source "$bMotionLocal/abstracts/$lang/abstracts.tcl"
		}
	}
}


# this is to update people from the old abstracts to the new abstracts.
# it only needs to be run once, and should be removed afterwards
proc bMotion_abstract_check {  } {
	global bMotionInfo bMotionModules
	set lang $bMotionInfo(language)
	set dir "$bMotionModules/abstracts/$lang"
	if { ![file exists $dir] } {
		file mkdir $dir
	}
	set files [glob -nocomplain "$bMotionModules/abstracts/*.txt"]
	if { [llength $files] == 0} {
		return 0
	}
	foreach f $files {
		catch {
			[file rename -force -- $f "${dir}/"]
		}
	}
}


# filter out stuff from an abstract
proc bMotion_abstract_filter { abstract filter } {
	if [bMotion_redis_available] {
		bMotion_log "abstracts" "WARN" "Warning: bMotion_abstract_filter not currently implemented"
		return
	}

	global bMotion_abstract_contents bMotion_abstract_ondisk

	set index [lsearch -exact $bMotion_abstract_ondisk $abstract]
	if {$index > -1} {
		bMotion_abstract_load $abstract
	}

	set contents [list]
	catch {
		set contents $bMotion_abstract_contents($abstract)
	}

	if {[llength $contents] == 0} {
		if {$abstract != "_all"} {
			bMotion_log "abstracts" "WARN" "bMotion_abstract_filter: can't get contents for $abstract"
		}
		return
	}

	set new_contents [list]
	set initial_size [llength $contents]

	foreach element $contents {
		bMotion_log "abstracts" "DEBUG" "considering $element for filtering"
		set do_filter 0
		foreach filter_text $filter {
			if {(!$do_filter) && [regexp $filter_text $element]} {
				bMotion_log "abstracts" "DEBUG" "abstract $abstract element $element matches filter $filter_text, dropping"
				set do_filter 1
			}
		}
		if {!$do_filter} {
			lappend new_contents $element
		}
	}

	set new_size [llength $new_contents]
	set diff [expr $initial_size - $new_size]

	if {$diff > 0} {
		bMotion_log "abstracts" "INFO" "abstract $abstract reduced by $diff items with filter $filter"
		set bMotion_abstract_contents($abstract) $new_contents
		bMotion_abstract_save $abstract
	}
}


# apply a filter to an abstract, if it has one defined
proc bMotion_abstract_apply_filter { abstract } {
	if [bMotion_redis_available] {
		bMotion_log "abstracts" "WARN" "Warning: bMotion_abstract_apply_filter not currently implemented"
		return
	}
	global bMotion_abstract_filters

	set filter ""
	catch {
		set filter $bMotion_abstract_filters($abstract)
	}
	if {$filter == ""} {
		return
	}

	bMotion_abstract_filter $abstract $filter
	catch {
		set filter $bMotion_abstract_filter(_all)
		bMotion_log "abstracts" "DEBUG" "abstract: found an _all filter, applying to $abstract"
		bMotion_abstract_filter $abstract $filter
	}

}


# register a filter for an abstract
proc bMotion_abstract_add_filter { abstract filter_text } {
	if [bMotion_redis_available] {
		bMotion_log "abstracts" "WARN" "Warning: bMotion_abstract_add_filter not currently implemented"
		return
	}
	global bMotion_abstract_filters

	lappend bMotion_abstract_filters($abstract) $filter_text

	bMotion_log "abstracts" "INFO" "registered filter /$filter_text/ for abstract $abstract"

	# apply it now
	bMotion_abstract_apply_filter $abstract
}


# nuke all filters
proc bMotion_abstract_flush_filters { } {
	if [bMotion_redis_available] {
		bMotion_log "abstracts" "WARN" "Warning: bMotion_abstract_flush_filter not currently implemented"
		return
	}
	global bMotion_abstract_filters

	unset bMotion_abstract_filters
	array set bMotion_abstract_filters {}
}


# implementation-independent way to get all filters
proc bMotion_abstract_list_filters { } {
	if [bMotion_redis_available] {
		bMotion_log "abstracts" "WARN" "Warning: bMotion_abstract_list_filter not currently implemented"
		return
	}
	global bMotion_abstract_filters
	return $bMotion_abstract_filters
}


# implementation-independent way to get all abstract names
proc bMotion_abstract_get_names { } {
	if [bMotion_redis_available] {
		global bMotionInfo
		set lang $bMotionInfo(language)
		return [bMotion_redis_cmd keys "abstract:$lang:*"]
	}

	global bMotion_abstract_contents
	return [array names bMotion_abstract_contents]
}


# clear an abstract (used when there have been significant changes to distribution)
# abstract must have been registered in advance!
proc bMotion_abstract_reset { abstract } {
	bMotion_log "abstracts" "TRACE" "bMotion_abstract_reset $abstract"
	if [bMotion_redis_available] {
		global bMotionInfo
		set lang $bMotionInfo(language)
		bMotion_redis_cmd del abstract:$lang:$abstract
	}

	global bMotion_abstract_contents bMotion_abstract_ondisk

	set index [lsearch -exact $bMotion_abstract_ondisk $abstract]
	if {$index > -1} {
		bMotion_abstract_load $abstract
	}

	set bMotion_abstract_contents($abstract) [list]
	bMotion_abstract_save $abstract
}


bind time - "* * * * *" bMotion_abstract_auto_gc

# the check has to be run to update old systems
bMotion_abstract_check
# we have to revive at least one language
bMotion_abstract_revive_language


bMotion_log "abstracts" "INFO" "abstract module loaded"

