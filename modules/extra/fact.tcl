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


if {![info exists bMotionFactTimestamps]} {
  #init timestamps
  foreach fact [array names bMotionFacts] {
    set bMotionFactTimestamps($fact) [clock seconds]
  }
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
      if [regexp {([^ ]+) (.+)} $line matches item fact] {
        #no timestamp
        set timestamp [clock seconds]
      } else {
        regexp {([^ ]+ _([0-9]+)_ (.+)} $line matches item timestamp fact
      }

      if {![info exists bMotionFacts($item)]} {

        set bMotionFacts($item) [list]

      }

      set bMotionFactTimestamps($item) $timestamp

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
  global bMotionFactTimestamps


  bMotion_putloglev 1 * "Saving facts to $bMotionModules/facts/facts.txt"



  set fileHandle [open "$bMotionModules/facts/facts.txt" "w"]



  set items [array names bMotionFacts]

  foreach item $items {

    foreach fact $bMotionFacts($item) {

      set timestamp [clock seconds]
      catch {
        set timestamp $bMotionFactTimestamps($item)
      }
      puts $fileHandle "$item _${timestamp}_ $fact"

    }

  }



  close $fileHandle

}



proc bMotion_facts_auto_save { min hr a b c } {

  putlog "bMotion: autosaving facts..."

  bMotion_facts_save
  bMotion_facts_gc
}



proc bMotion_facts_forget_all { fact } {

  global bMotionFacts bMotionModules
  global bMotionFactTimestamps


  #drop the array element

  unset bMotionFacts($fact)

  catch {
    unset bMotionFactTimestamps($fact)
  }


  #resave to delete

  bMotion_facts_save

}

proc bMotion_facts_gc { } {
  global bMotionFacts bMotionFactTimestamps
  #delete facts with more than 30 definitions
  foreach item [array names bMotionFacts] {
    if {[llength $bMotionFacts($item)] > 30} {
      bMotion_putloglev d * "fact: item $item has too many definitions, deleting"
      bMotion_facts_forget_all $item
    }
  }

  #if we have more than 1000 items, delete those older than a month
  if {[llength [array names bMotionFacts]] > 1000} {
    set limit [expr [clock seconds] - (60 * 60 * 24 * 31)]
    foreach item [array names bMotionFactTimestamps] {
      if {$bMotionFactTimestamps($item) < $limit} {
        bMotion_putloglev d * "fact: item $item is too old, deleting"
        bMotion_facts_forget_all $item
      }
    }
  }
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