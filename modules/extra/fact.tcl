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

# maximum number of things about which facts can be known
set bMotion_facts_max_items 500

# maximum number of facts to know about an item
set bMotion_facts_max_facts 20

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
  set count 0

  while {![eof $fileHandle]} {
    if {$line != ""} {
      regexp {([^ ]+) (.+)} $line matches item fact
      if {![info exists bMotionFacts($item)]} {
        set bMotionFacts($item) [list]
      }
      if {[lsearch -exact $bMotionFacts($item) $fact] == -1} {
        lappend bMotionFacts($item) $fact
      } else {
        bMotion_putloglev 4 * "dropping duplicate fact $fact for item $item"
        set needReSave 1
      }
      
      incr count
      
      if {[expr $count % 1000] == 0} {
        
      putlog "  still loading facts: $count ..."
      
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
  global bMotion_facts_max_facts
  global bMotion_facts_max_items

  set tidy 0
  set tidyfact 0
  set count 0 

  bMotion_putloglev 1 * "Saving facts to $bMotionModules/facts/facts.txt"

  set fileHandle [open "$bMotionModules/facts/facts.txt" "w"]

  set items [array names bMotionFacts]
  if {[llength $items] > $bMotion_facts_max_items} {
    putlog "Too many items are known ([llength $items] > $bMotion_facts_max_items), tidying up"
    set tidy 1
  }
  foreach item $items {
    if {$tidy} {
      if {[rand 100]< 10} {
        #clear array entry
        unset bMotionFacts($item)
        incr count
        continue
      }
    }
    if {[llength $bMotionFacts($item)] > $bMotion_facts_max_facts} {
      set tidyfact 1
    } else {
      set tidyfact 0
    }
    foreach fact $bMotionFacts($item) {
      if {$tidyfact} {
        if {[rand 100] < 10} {
          #less critical so we won't waste time trying to delete from memory too :)
          continue
        }
        puts $fileHandle "$item $fact"
      }
    }
  }
  if {$tidy} {
    putlog "$count facts have been forgo.. los... delet... thingy *dribbles*"
  }
  close $fileHandle
}

proc bMotion_facts_auto_save { min hr a b c } {
  putlog "bMotion: autosaving facts..."
  bMotion_facts_save
}

proc bMotion_facts_forget_all { fact } {
  global bMotionFacts bMotionModules

  #drop the array element
  unset bMotionFacts($fact)

  #resave to delete
  bMotion_facts_save
}

# save facts every hour
bind time - "01 * * * *" bMotion_facts_auto_save

# load facts at startup
catch {
  if {$bMotion_loading == 1} {
    bMotion_putloglev d * "autoloading facts..."
    bMotion_facts_load
  }

}


putlog "loaded fact module"