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

proc bMotion_plugin_admin_flood { handle idx { arg "" }} {
  global bMotion_flood_info bMotion_flood_last bMotion_flood_lasttext bMotion_flood_undo
 
  #flood show <handle>
  if [regexp -nocase {show ([^ ]+)} $arg matches handle] {
    putidx $idx "bMotion: Flood for $handle is [bMotion_flood_get $handle]\r"
    return 0
  }

  #flood set <handle> <n>
  if [regexp -nocase {set ([^ ]+) (.+)} $arg matches handle value] {
    set bMotion_flood_info($handle) $value
    putidx $idx "bMotion: flood for $handle set to 0\r"
    return 0
  }


  #status
  if [regexp -nocase {status} $arg] {
    set handles [array names bMotion_flood_info]
    putidx $idx "bMotion: current flood info:\r"
    foreach handle $handles {
      putidx $idx "$handle: [bMotion_flood_get $handle]\r"
    }
    return 0
  }

  #all else fails, list help
  putidx $idx ".bmadmin flood \[show|set|status\]\r"
  return 0
}

# register the plugin
bMotion_plugin_add_admin "flood" "^flood" n "bMotion_plugin_admin_flood" "any"