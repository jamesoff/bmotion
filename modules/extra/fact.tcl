# bMotion facts module

# $Id$

###############################################################################

# This is a bMotion plugin

# Copyright (C) James Michael Seward 2000-2002

#

# This program is covered by the GPL, please refer the to LICENCE file in the

# distribution; further information can be found in the headers of the scripts

# in the modules directory.

###############################################################################


# initialise
if {![info exists bMotionFacts]} {

  set bMotionFacts(what,bmotion) [list "a very nice script"]
}

proc bMotion_facts_load { } {
  global bMotionFacts bMotionModules

  bMotion_putloglev 1 * "Attempting to load $bMotionModules/facts/facts.txt"

  if {![file exists "$bMotionModules/facts/facts.txt"]} {
    return
  }

  set fileHandle [open "$bMotionModules/facts/facts.txt" "r"]
  set line [gets $fileHandle]

  set needResave 0

  while {![eof $fileHandle]} {
    if {$line != ""} {
      regexp {([^ ]+) (.+)} $line matches item fact
      if {![info exists bMotionFacts($item)]} {
        set bMotionFacts($item) [list]
      }
      if {[lsearch -exact $bMotionFacts($item) $fact] == -1} {
        lappend bMotionFacts($item) $fact
      } else {
        bMotion_putloglev 2 * "dropping duplicate fact $fact for item $item"
        set needReSave 1
      }
    }
    set line [gets $fileHandle]
  }

  if {[info exists fileHandle]} {
    close $fileHandle
  }

  if {$needReSave} {
    bMotion_facts_save
  }
}

proc bMotion_facts_save { } {
  global bMotionFacts bMotionModules

  bMotion_putloglev 1 * "Saving facts to $bMotionModules/facts/facts.txt"

  set fileHandle [open "$bMotionModules/facts/facts.txt" "w"]

  set items [array names bMotionFacts]
  foreach item $items {
    foreach fact $bMotionFacts($item) {
      puts $fileHandle "$item $fact"
    }
  }

  close $fileHandle
}

proc bMotion_facts_auto_save { min hr a b c } {
  putlog "bMotion: autosaving facts..."
  bMotion_facts_save
}

# save facts every hour
bind time - "01 * * * *" bMotion_facts_auto_save

# load facts at startup
catch {
  bMotion_putloglev d * "autoloading facts..."
  bMotion_facts_load
}