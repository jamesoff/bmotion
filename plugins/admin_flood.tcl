# bMotion: admin plugin file for flood mangement
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


### management version

proc bMotion_plugin_management_flood { handle { arg "" } } {
  global bMotion_flood_info bMotion_flood_last bMotion_flood_lasttext bMotion_flood_undo

  #flood show <handle>
  if [regexp -nocase {show ([^ ]+)} $arg matches handle] {
    bMotion_putadmin "bMotion: Flood for $handle is [bMotion_flood_get $handle]"
    return 0
  }

  #flood set <handle> <n>
  if [regexp -nocase {set ([^ ]+) (.+)} $arg matches handle value] {
    set bMotion_flood_info($handle) $value
    bMotion_putadmin "bMotion: flood for $handle set to 0"
    return 0
  }


  #status
  if [regexp -nocase {status} $arg] {
    set handles [array names bMotion_flood_info]
    bMotion_putadmin "bMotion: current flood info:"
    foreach handle $handles {
      bMotion_putadmin "$handle: [bMotion_flood_get $handle]"
    }
    return 0
  }

  #all else fails, list help
  bMotion_putadmin "usage: flood \[show|set|status\]"
  return 0
}

bMotion_plugin_add_management "flood" "^flood" n "bMotion_plugin_management_flood"
