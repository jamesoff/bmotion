# bMotion: admin plugin file for abstracts
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_plugin_admin_abstract { handle { arg "" }} {

  #abstract show <name>
  if [regexp -nocase {show ([^ ]+)} $arg matches name] {
    set result [bMotion_abstract_all $name]
    bMotion_putadmin "Abstract $name has [llength $result] items."
    set i 0
    foreach a $result {
      bMotion_putadmin "$i: $a"
      incr i
    }
    return 0
  }

  #abstract gc
  if [regexp -nocase {gc} $arg matches] {
    bMotion_putadmin "Garbage collecting..."
    bMotion_abstract_gc
    return 0
  }


  #status
  if [regexp -nocase {status} $arg] {
    global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age
    global bMotion_abstract_ondisk

    set mem 0
    set disk 0

    set handles [array names bMotion_abstract_contents]
    bMotion_putadmin "bMotion abstract info info:\r"
    foreach handle $handles {      
      set diff [expr [clock seconds]- $bMotion_abstract_timestamps($handle)]
      bMotion_putadmin "$handle: [llength [bMotion_abstract_all $handle]] items, $diff seconds since used"
      incr mem
    }
    foreach handle $bMotion_abstract_ondisk {
      bMotion_putadmin "$handle: on disk"
      incr disk
    }
    bMotion_putadmin "[expr $mem + $disk] total abstracts, $mem loaded, $disk on disk"
    return 0
  }

  if [regexp -nocase {info (.+)} $arg matches name] {
    set result [bMotion_abstract_all $name]
    bMotion_putadmin "Abstract $name has [llength $result] items.\r"
    return 0
  }

  if [regexp -nocase {delete (.+) (.+)} $arg matches name index] {
    bMotion_putadmin "Deleting element $index from abstract $name...\r"
    bMotion_abstract_delete $name $index
    return 0
  }

  #all else fails, list help
  bMotion_putadmin ".bmadmin abstract \[show|gc|status\]\r"
  return 0
}

# register the plugin
bMotion_plugin_add_management "abstract" "^abstract" n "bMotion_plugin_admin_abstract" "any"