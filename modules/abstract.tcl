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
# The abstracts will be stored in ./abstracts/<abstract name>.txt in the bMotion directory. The 
# fileformat is simply one per line.

#
set bMotion_abstract_max_age 300

# initialise the arrays

if {![info exists bMotion_abstract_contents]} {
  set bMotion_abstract_contents(dummy) ""
  set bMotion_abstract_timestamps(dummy) 1
  set bMotion_abstract_ondisk [list]
}

# garbage collect the abstracts arrays
proc bMotion_abstract_gc { } {
  global bMotion_abstract_contents bMotion_abstract_timestamps
  global bMotion_abstract_max_age bMotion_abstract_ondisk

  bMotion_putloglev 2 * "Garbage collecting abstracts..."

  set abstracts [array names bMotion_abstract_contents]
  set limit [expr [clock seconds] - $bMotion_abstract_max_age]

  set expiredList ""
  set expiredCount 0

  foreach abstract $abstracts {
    if {($bMotion_abstract_timestamps($abstract) < $limit) && ($bMotion_abstract_timestamps($abstract) > 0)} {
      append expiredList "$abstract "
      incr expiredCount
      unset bMotion_abstract_contents($abstract)
      set bMotion_abstract_timestamps($abstract) 0
      lappend bMotion_abstract_ondisk $abstract
    }
  }

  if {$expiredList != ""} {
    bMotion_putloglev d * "expired $expiredCount abstracts: $expiredList"
  }

}

proc bMotion_abstract_register { abstract } {
  global bMotion_abstract_contents bMotion_abstract_timestamps
  global bMotionModules bMotion_testing bMotion_loading

  #set timestamp to now
  set bMotion_abstract_timestamps($abstract) [clock seconds]

  #load any existing abstracts
  if [file exists "[pwd]/$bMotionModules/abstracts/${abstract}.txt"] {
    bMotion_abstract_load $abstract
  } else {
    #file doesn't exist - create an empty one
    #create blank array for it
    set bMotion_abstract_contents($abstract) [list]
    bMotion_putloglev 1 * "Creating new abstract file for $abstract"
    set fileHandle [open "[pwd]/$bMotionModules/abstracts/${abstract}.txt" "w"]
    puts $fileHandle " "
  }

  if {[info exists fileHandle]} {
    close $fileHandle
  }  
}

proc bMotion_abstract_load { abstract } {
  global bMotion_abstract_contents bMotion_abstract_timestamps
  global bMotionModules bMotion_abstract_ondisk
  global bMotion_loading bMotion_testing

  bMotion_putloglev 1 * "Attempting to load $bMotionModules/abstracts/${abstract}.txt"

  if {![file exists "$bMotionModules/abstracts/${abstract}.txt"]} {
    return
  }

  #create blank array for it
  set bMotion_abstract_contents($abstract) [list]

  #set timestamp to now
  set bMotion_abstract_timestamps($abstract) [clock seconds]

  if {$bMotion_testing} {
    return 0
  }

  #remove from ondisk list
  set index [lsearch -exact $bMotion_abstract_ondisk $abstract]
  set bMotion_abstract_ondisk [lreplace $bMotion_abstract_ondisk $index $index]

  set fileHandle [open "$bMotionModules/abstracts/${abstract}.txt" "r"]
  set line [gets $fileHandle]
  set needReSave 0
  set count 0

  while {![eof $fileHandle]} {
    set line [string trim $line]
    if {$line != ""} {
      if {[lsearch -exact $bMotion_abstract_contents($abstract) $line] == -1} {
        lappend bMotion_abstract_contents($abstract) $line
      } else {
        bMotion_putloglev 4 * "dropping duplicate $line for abstract $abstract"
        set needReSave 1
      }
      incr count
      if {[expr $count % 200] == 0} {
        putlog "  still loading abstract $abstract: $count ..."
      }
    }
    set line [gets $fileHandle]
  }

  if {[info exists fileHandle]} {
    close $fileHandle
  }

  if {$needReSave} {
    bMotion_abstract_save $abstract
  }
}

proc bMotion_abstract_add { abstract text {save 1} } {
  global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age
  global bMotionModules

  bMotion_putloglev 2 * "Adding '$text' to abstract '$abstract'"

  if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
    #bMotion_abstract_load $abstract
    #new more efficient way
    # - append it to the file regardless
    # - it can be filtered on load

    bMotion_putloglev 2 * "updating abstracts '$abstract' on disk"
    if {$save} {
      set fileHandle [open "[pwd]/$bMotionModules/abstracts/${abstract}.txt" "a+"]
      puts $fileHandle $text
      close $fileHandle
    }
    return
  }

  if {[lsearch -exact $bMotion_abstract_contents($abstract) $text] == -1} {
    lappend bMotion_abstract_contents($abstract) $text
    if {$save} {
      bMotion_putloglev 2 * "updating abstracts '$abstract' on disk and in memory"
      set fileHandle [open "[pwd]/$bMotionModules/abstracts/${abstract}.txt" "a+"]
      puts $fileHandle $text
      close $fileHandle
    }
  }
}

proc bMotion_abstract_save { abstract } {
  global bMotion_abstract_contents
  global bMotionModules bMotion_testing bMotion_loading

  #don't save if we're starting up else we'll lose saved stuff
  if {$bMotion_testing} {
    return 0
  }

  bMotion_putloglev 1 * "Saving abstracts '$abstract' to disk"

  set fileHandle [open "[pwd]/$bMotionModules/abstracts/${abstract}.txt" "w"]
  foreach a $bMotion_abstract_contents($abstract) {
    puts $fileHandle $a
  }
  close $fileHandle
}

proc bMotion_abstract_all { abstract } {
  global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age

  if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
    bMotion_abstract_load $abstract
  }

  return $bMotion_abstract_contents($abstract)
}

proc bMotion_abstract_get { abstract } {
  global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age

  bMotion_putloglev 2 * "getting abstract $abstract"

  if {![info exists bMotion_abstract_timestamps($abstract)]} {
    return ""
  }

  if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
    bMotion_putloglev d * "abstract $abstract has been unloaded, reloading..."
    bMotion_abstract_load $abstract
  }

  set bMotion_abstract_timestamps($abstract) [clock seconds]

  return [lindex $bMotion_abstract_contents($abstract) [rand [llength $bMotion_abstract_contents($abstract)]]]
}

proc bMotion_abstract_delete { abstract index } {
  global bMotion_abstract_contents 

  set bMotion_abstract_contents($abstract) [lreplace $bMotion_abstract_contents($abstract) $index $index]
  bMotion_abstract_save $abstract
}

proc bMotion_abstract_auto_gc { min hr a b c } {
  bMotion_abstract_gc
}

proc bMotion_abstract_batchadd { abstract stuff } {
  bMotion_putloglev d * "batch-adding to $abstract"
  foreach i $stuff {
    bMotion_abstract_add $abstract $i 0
  }
  bMotion_abstract_save $abstract
}

bind time - "* * * * *" bMotion_abstract_auto_gc