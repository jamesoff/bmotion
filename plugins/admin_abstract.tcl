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

proc bMotion_plugin_admin_abstract { handle idx { arg "" }} {

  #abstract show <name>
  if [regexp -nocase {show ([^ ]+)} $arg matches name] {
    set result [bMotion_abstract_all $name]
    putidx $idx "Abstract $name has [llength $result] items.\r"
    foreach a $result {
      putidx $idx $a
    }
    return 0
  }

  #abstract gc
  if [regexp -nocase {gc} $arg matches] {
    putidx $idx "Garbage collecting...\r"
    bMotion_abstract_gc
    return 0
  }


  #status
  if [regexp -nocase {status} $arg] {
    global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age
    global bMotion_abstract_ondisk
    set handles [array names bMotion_abstract_contents]
    putidx $idx "bMotion abstract info info:\r"
    foreach handle $handles {      
      set diff [expr [clock seconds]- $bMotion_abstract_timestamps($handle)]
      putidx $idx "$handle: [llength [bMotion_abstract_all $handle]] items, $diff seconds since used"
    }
    foreach handle $bMotion_abstract_ondisk {
      putidx $idx "$handle: on disk"
    }
    return 0
  }

  #all else fails, list help
  putidx $idx ".bmadmin abstract \[show|gc|status\]\r"
  return 0
}

# register the plugin
bMotion_plugin_add_admin "abstract" "^abstract" n "bMotion_plugin_admin_abstract" "any"