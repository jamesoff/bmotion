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

proc bMotion_plugin_management_fact { handle { arg "" }} {

  global bMotionFacts

  #fact show <type> <name>
  if [regexp -nocase {show ([^ ]+) ([^ ]+)} $arg matches t name] {
    set known $bMotionFacts($t,$name)
    bMotion_putadmin "Known '$t' facts about: $name"
    set count 0
    foreach fact $known {
      bMotion_putadmin "$count: $fact"
      incr count
    }
    return 0
  }

  #status
  if [regexp -nocase {status} $arg] {
    set items [lsort [array names bMotionFacts]]
    set itemcount 0
    set factcount 0
    #bMotion_putadmin "Known facts:"
    foreach item $items {
      #bMotion_putadmin "$item ([llength $bMotionFacts($item)])"
      incr itemcount
      incr factcount [llength $bMotionFacts($item)]
    }
    bMotion_putadmin "Total: $factcount facts about $itemcount items"
    return 0
  }

  #all else fails, list help
  bMotion_putadmin {use: fact [show <type> <name>|status]}
  return 0
}

# register the plugin
bMotion_plugin_add_management "fact" "^fact" n "bMotion_plugin_management_fact" "any"