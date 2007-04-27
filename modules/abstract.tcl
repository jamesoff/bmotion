# bMotion - Abstract Handling
#
# $Id$
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2003
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
  set bMotion_abstract_contents(dummy) ""
  set bMotion_abstract_languages(dummy) "en"
  set bMotion_abstract_timestamps(dummy) 1
  set bMotion_abstract_ondisk [list]
	set bMotion_abstract_last_get(dummy) ""
}

#init our counters
bMotion_counter_init "abstracts" "faults"
bMotion_counter_init "abstracts" "pageouts"
bMotion_counter_init "abstracts" "gc"
bMotion_counter_init "abstracts" "gets"

set bMotion_abstract_dir "$bMotionLocal/abstracts/$bMotionInfo(language)"

# garbage collect the abstracts arrays
proc bMotion_abstract_gc { } {
	bMotion_putloglev 5 * "bMotion_abstract_gc"
  global bMotion_abstract_contents bMotion_abstract_timestamps
  global bMotion_abstract_max_age bMotion_abstract_ondisk
  global bMotionInfo bMotion_abstract_languages
  set lang $bMotionInfo(language)

  bMotion_putloglev 2 * "Garbage collecting abstracts..."

  bMotion_counter_incr "abstracts" "gc"

  set abstracts [array names bMotion_abstract_contents]
  set limit [expr [clock seconds] - $bMotion_abstract_max_age]

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
      bMotion_counter_incr "abstracts" "pageouts"
    }
  }

  if {$expiredList != ""} {
    bMotion_putloglev d * "expired $expiredCount abstracts: $expiredList"
  }
}

proc bMotion_abstract_register { abstract { stuff "" } } {
	bMotion_putloglev 5 * "bMotion_abstract_register ($abstract)"
  global bMotion_abstract_contents bMotion_abstract_timestamps
  global bMotionModules bMotion_testing bMotion_loading
  global bMotionInfo bMotion_abstract_languages bMotion_abstract_dir
	global bMotion_abstract_last_get

  #set timestamp to now
  set bMotion_abstract_timestamps($abstract) [clock seconds]
  set lang $bMotionInfo(language)
	set bMotion_abstract_last_get($abstract) ""

  #load any existing abstracts
  if [file exists "$bMotion_abstract_dir/${abstract}.txt"] {
    bMotion_abstract_load $abstract
  } else {
    # check that the language directory exists while we're at it
    if { ![file exists $bMotion_abstract_dir] } {
      [file mkdir $bMotion_abstract_dir]
    }
    #file doesn't exist - create an empty one
    #create blank array for it
    set bMotion_abstract_contents($abstract) [list]
    set bMotion_abstract_languages($abstract) "$lang"
    bMotion_putloglev 1 * "Creating new abstract file for $abstract"
    set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "w"]
    puts $fileHandle " "
  }

  if {[info exists fileHandle]} {
    close $fileHandle
  }

	if {$stuff != ""} {
		# batch-add at the same time
		bMotion_putloglev d * "Batchadding during registration for $abstract"
		bMotion_abstract_batchadd $abstract $stuff
	}
}

proc bMotion_abstract_load { abstract } {
	bMotion_putloglev 5 * "bMotion_abstract_load ($abstract)"
  global bMotion_abstract_contents bMotion_abstract_timestamps
  global bMotionModules bMotion_abstract_ondisk
  global bMotion_loading bMotion_testing
  global bMotionInfo bMotion_abstract_languages
	global bMotion_abstract_dir
  set lang $bMotionInfo(language)

  bMotion_putloglev 1 * "Attempting to load $bMotion_abstract_dir/${abstract}.txt"

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
		bMotion_putloglev d * "Shrunk abstract $abstract by [expr $count - $newcount] items by de-duping"
		set needReSave 1
	}

  if {[info exists fileHandle]} {
    close $fileHandle
  }

  if {$needReSave} {
    bMotion_abstract_save $abstract
  }
}

proc bMotion_abstract_add { abstract text {save 1} } {
	bMotion_putloglev 5 * "bMotion_abstract_add ($abstract, $text, $save)"
  global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age
  global bMotionModules bMotionInfo
	global bMotion_abstract_dir
  set lang $bMotionInfo(language)

  bMotion_putloglev 2 * "Adding '$text' to abstract '$abstract'"

  if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
    #bMotion_abstract_load $abstract
    #new more efficient way
    # - append it to the file regardless
    # - it can be filtered on load

    bMotion_putloglev 2 * "updating abstracts '$abstract' on disk"
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
      bMotion_putloglev 2 * "updating abstracts '$abstract' on disk and in memory"
      set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "a+"]
      puts $fileHandle $text
      close $fileHandle
    }
  }
}

proc bMotion_abstract_save { abstract } {
	bMotion_putloglev 5 * "bMotion_abstract_save"
  global bMotion_abstract_contents
  global bMotionModules bMotion_testing bMotion_loading
  global bMotion_abstract_max_number bMotionInfo bMotion_abstract_languages
	global bMotion_abstract_dir
  set lang $bMotionInfo(language)

  if {$lang != $bMotion_abstract_languages($abstract) } {
    bMotion_putloglev 1 * "Did not save '$abstract' to disk (wrong language)"
    return 0
  }

  set tidy 0
  set count 0
  set drop_count 0

  #don't save if we're starting up else we'll lose saved stuff
  if {$bMotion_testing} {
    return 0
  }

  bMotion_putloglev 1 * "Saving abstracts '$abstract' to disk"

  set fileHandle [open "$bMotion_abstract_dir/${abstract}.txt" "w"]
  set number [llength $bMotion_abstract_contents($abstract)]
  if {$number > $bMotion_abstract_max_number} {
    putlog "Abstract $abstract has too many elements ($number > $bMotion_abstract_max_number), tidying up"
    set tidy 1
  }
  foreach a $bMotion_abstract_contents($abstract) {
    if {$tidy} {
      if {[rand 100] < 10} {
        bMotion_putloglev 3 * "Dropped '$a' from abstract $abstract"
        incr drop_count
        continue
      }
    }
    puts $fileHandle $a
    incr count
  }
  if {$tidy} {
    putlog "Abstract $abstract now has $count elements ($drop_count fewer)"
  }
  close $fileHandle
}

proc bMotion_abstract_all { abstract } {
	bMotion_putloglev 5 * "bMotion_abstract_all ($abstract)"
  global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age

	if [info exists bMotion_abstract_timestamps($abstract)] {
		if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
			bMotion_abstract_load $abstract
		}

		return $bMotion_abstract_contents($abstract)
	} else {
		#abstract doesn't exist
		bMotion_putloglev d * "bMotion_abstract_all: couldn't find abstract '$abstract' in new system"
		global $abstract
		set var [subst $$abstract]
		
		return $var
	}

}

proc bMotion_abstract_exists { abstract } {
	bMotion_putloglev 5 * "bMotion_abstract_exists ($abstract)"
  global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age bMotion_abstract_last_get

  bMotion_putloglev 2 * "checking for existence of abstract $abstract"

  if {![info exists bMotion_abstract_timestamps($abstract)]} {
    return 0
  }
	return 1
}

proc bMotion_abstract_get { abstract } {
	bMotion_putloglev 5 * "bMotion_abstract_get ($abstract)"
  global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age bMotion_abstract_last_get bMotionInfo

  bMotion_putloglev 2 * "getting abstract $abstract"

  if {![info exists bMotion_abstract_timestamps($abstract)]} {
    return ""
  }

  bMotion_counter_incr "abstracts" "gets"

  if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
    bMotion_putloglev d * "abstract $abstract has been unloaded, reloading..."
    bMotion_counter_incr "abstracts" "faults"
    bMotion_abstract_load $abstract
  }

  set bMotion_abstract_timestamps($abstract) [clock seconds]

	if {![info exists bMotion_abstract_last_get($abstract)]} {
		set bMotion_abstract_last_get($abstract) ""
	}

	# look for male and female versions, and merge in if needed
	if [bMotion_abstract_exists "${abstract}_$bMotionInfo(gender)"] {
		# mix-in the gender one with the vanilla one
		bMotion_putloglev 1 * "mixing in $bMotionInfo(gender) version of $abstract"
		set final_version [concat $bMotion_abstract_contents($abstract) [bMotion_abstract_all "${abstract}_$bMotionInfo(gender)"]]
	} else {
		set final_version $bMotion_abstract_contents($abstract)
	}


	if {[llength $final_version] == 0} {
		bMotion_putloglev d * "abstract '$abstract' is empty!"
		return ""
	} else {
		set retval [lindex $final_version [rand [llength $final_version]]]
		if {[llength $final_version] > 1} {
			set count 0
			while {$retval == $bMotion_abstract_last_get($abstract)} {
				putloglev d * "fetched repeat value for abstract $abstract, trying again"
				putloglev 1 * "this: $retval ... last: $bMotion_abstract_last_get($abstract)"
				set retval [lindex $final_version [rand [llength $final_version]]]
				incr count
				if {$count > 5} {
					putloglev d * "trying too hard to find non-dupe for abstract $abstract, giving up and using $retval"
					break
				}
			}
		}
	}

	set bMotion_abstract_last_get($abstract) $retval
	bMotion_putloglev 5 * "successfully got '$retval' from '$abstract'"
	return $retval
}

proc bMotion_abstract_delete { abstract index } {
	bMotion_putloglev 5 * "bMotion_abstract_delete ($abstract, $index)"
  global bMotion_abstract_contents

  set bMotion_abstract_contents($abstract) [lreplace $bMotion_abstract_contents($abstract) $index $index]
  bMotion_abstract_save $abstract
}

proc bMotion_abstract_auto_gc { min hr a b c } {
  bMotion_abstract_gc
}

proc bMotion_abstract_batchadd { abstract stuff } {
  bMotion_putloglev 1 * "batch-adding to $abstract"
  foreach i $stuff {
    bMotion_abstract_add $abstract $i 0
  }
  bMotion_abstract_save $abstract
}

# flush all of the abstracts to disk
# this was created for changing languages on the fly. If you're using this
# for some other reason, then you might want to be sure.
proc bMotion_abstract_flush { } {
  global bMotionInfo bMotion_abstract_contents
  global bMotion_abstract_languages
  set lang $bMotionInfo(language)
  set abstracts [array names bMotion_abstract_contents]
  foreach abstract $abstracts {
    set storedLang $bMotion_abstract_languages($abstract)
    if { $abstract != "dummy" && $storedLang == $lang } {
      bMotion_abstract_save $abstract
      unset bMotion_abstract_contents($abstract)
      unset bMotion_abstract_languages($abstract)
    }
  }
  set bMotion_abstract_contents(dummy) ""
  set bMotion_abstract_languages(dummy) ""
  set bMotion_abstract_timestamps(dummy) 1
  set bMotion_abstract_ondisk [list]
}

# this loads language abstracts for the current language in bMotionInfo
proc bMotion_abstract_revive_language { } {
  global bMotionSettings bMotionInfo bMotionModules
  global bMotion_abstract_contents

  set lang $bMotionInfo(language)

  bMotion_putloglev 2 * "bMotion: reviving language ($lang) abstracts"
  set languages [split $bMotionSettings(languages) ","]
  # just check if it's ok to use this language
  set ok 0
  foreach language $languages {
    if { $lang == $language } {
      set ok 1
    }
  }
  if { $ok != 1 } {
    bMotion_putloglev 2 * "bMotion: language not found, cannot revive"
    return -1
  }
  # if the default abstracts exists, use it first
  if { [file exists "$bMotionModules/abstracts/$lang/abstracts.tcl"] } {
    catch {
      source "$bMotionModules/abstracts/$lang/abstracts.tcl"
    }
  } else {
    bMotion_putloglev 2 * "bMotion: language default abstracts not found"
  }
  # then we need to load any others
  set files [glob -nocomplain "$bMotionModules/abstracts/$lang/*.txt"]
  if { [llength $files] == 0} {
    return 0
  }
  foreach f $files {
    set pos [expr [string last "/" $f] + 1]
    set dot [expr [string last ".txt" $f] - 1]
    set abstract [string range $f $pos $dot]
    bMotion_putloglev 2 * "checking $abstract"
    set len 0
    catch { set len [llength $bMotion_abstract_contents($abstract)] } val
    if { $val != "$len" } {
      bMotion_abstract_load $abstract
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
    [file mkdir $dir]
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

bind time - "* * * * *" bMotion_abstract_auto_gc

# the check has to be run to update old systems
bMotion_abstract_check
# we have to revive at least one language
bMotion_abstract_revive_language
