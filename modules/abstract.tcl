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
# NOTE: This plugin should be loaded before plugins as they will need it to register abstracts
#
# The abstracts will be stored in ./abstracts/<abstract name>.txt in the bMotion directory. The 
# fileformat is simply one per line.

#
set bMotion_abstract_max_age 300

# initialise the arrays

if {![info exists bMotion_abstract_contents]} {
  set bMotion_abstract_contents(dummy) ""
  set bMotion_abstract_timestamps(dummy) 1
}

# garbage collect the abstracts arrays
proc bMotion_abstract_gc { } {
  global bMotion_abstract_contents bMotion_abstract_timestamps
  global bMotion_abstract_max_age

  set abstracts [array names $bMotion_abstract_contents]
  set limit [expr [clock seconds] - $bMotion_abstract_max_age]

  foreach abstract $abstract {
    if {($bMotion_abstract_timestamps($abstract) < $limit) && ($bMotion_abstract_timestamps($abstract) > 0)} {
      bMotion_putloglev d * "abstract $abstract has expired"
      unset bMotion_abstract_contents($abstract)
      set bMotion_abstract_timestamps($abstract) 0
    }
  }
}

proc bMotion_abstract_register { abstract } {
  global bMotion_abstract_contents bMotion_abstract_timestamps

  #set timestamp to now
  set bMotion_abstract_timestamps($abstract) [clock seconds]

  #load any existing abstracts
  if [file exists "$bMotionModules/abstracts/${abstract}.txt"] {
    bMotion_abstract_load $abstract
  } else {
    #file doesn't exist - create an empty one
    set fileHandle [open "$bMotionModules/abstracts/${abstract}.txt" "w"]
    puts $fileHandle " "
  }

  if {$fileHandle} {
    close $fileHandle
  }
}

proc bMotion_abstract_load { abstract } {
  global bMotion_abstract_contents bMotion_abstract_timestamps

  if {![file exists "$bMotionModules/abstracts/${abstract}.txt"]} {
    return
  }

  #set timestamp to now
  set bMotion_abstract_timestamps($abstract) [clock seconds]

  catch {
    set fileHandle [open "$bMotionModules/abstracts/${abstract}.txt" "r"]
    set line ""
    while [gets $fileHandle line] {
      if {[lsearch -exact $bMotion_abstract_contents($abstract) $line] > -1} {
        lappend bMotion_abstract_contents($abstract) $line
      }
    }
  }

  if {$fileHandle} {
    close $fileHandle
  }
}

proc bMotion_abstract_add { abstract text } {
  global bMotion_abstract_contents bMotion_abstract_timestamps

  if {[lsearch -exact $bMotion_abstract_contents($abstract) $text] > -1} {
    lappend bMotion_abstract_contents($abstract) $text
  }
  bMotion_abstract_save $abstract
}

proc bMotion_abstract_save { abstract } {
  global bMotion_abstract_contents 

  catch {
    set fileHandle [open "$bMotionModules/abstracts/${abstract}.txt" "w"]
    foreach abstract $bMotion_abstract_contents($abstract) {
      puts $fileHandle $abstract
    }
    close $fileHandle
  }
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

  if {$bMotion_abstract_timestamps($abstract) < [expr [clock seconds] - $bMotion_abstract_max_age]} {
    bMotion_abstract_load $abstract
  }

  return [lindex $bMotion_abstract_contents($abstract) [rand [llength $bMotion_abstract_contents($abstract)]]]
}

proc bMotion_abstract_delete { abstract index } {
  global bMotion_abstract_contents 

  set bMotion_abstract_contents($abstract) [lreplace $bMotion_abstract_contents($abstract) $index $index]
}
