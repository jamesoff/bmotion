# bMotion: admin plugin file for facts
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

proc bMotion_plugin_admin_fact { handle idx { arg "" }} {

  global bMotionFacts

  #fact show <type> <name>
  if [regexp -nocase {show ([^ ]+) ([^ ]+)} $arg matches t name] {
    set known $bMotionFacts($t,$name)
    putidx $idx "Known '$t' facts about: $name"
    set count 0
    foreach fact $known {
      putidx $idx "$count: $fact"
      incr count
    }
    return 0
  }

  #status
  if [regexp -nocase {status} $arg] {
    set items [lsort [array names bMotionFacts]]
    set itemcount 0
    set factcount 0
    putidx $idx "Known facts:"
    foreach item $items {
      putidx $idx "$item ([llength $bMotionFacts($item)])"
      incr itemcount
      incr factcount [llength $bMotionFacts($item)]
    }
    putidx $idx "Total: $factcount facts about $itemcount items"
    return 0
  }

  #all else fails, list help
  putidx $idx ".bmadmin fact \[show|status\]\r"
  return 0
}

# register the plugin
bMotion_plugin_add_admin "fact" "^fact" n "bMotion_plugin_admin_fact" "any"