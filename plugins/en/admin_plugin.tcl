# bMotion: admin plugin file for plugin mangement
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

proc bMotion_plugin_admin_plugins { handle idx { arg "" }} {
  #global bMotion_plugins_admin bMotion_plugins_simple
 
  #plugin remove <type> <id>
  if [regexp -nocase {remove ([^ ]+) (.+)} $arg matches t id] {
    putidx $idx "Removing $t plugin $id...\r"
    set full_array_name_for_upvar "bMotion_plugins_$t"
    upvar #0 $full_array_name_for_upvar TEH_ARRAY
    unset TEH_ARRAY($id)
    return 0
  }

  #enable a plugin
  if [regexp -nocase {enable ([^ ]+) (.+)} $arg matches t id] {
    if {$t == "output"} {
      putidx $idx "Enabling output plugin $id...\r"
      global bMotion_plugins_output
      set details $bMotion_plugins_output($id)
      set blah [split $details "¦"]
      set callback [lindex $blah 0]
      set enabled [lindex $blah 1]
      set language [lindex $blah 2]
      if {$enabled == 1} {
        putidx $idx "... it's already enabled.\r"
        return 0
      }
      set bMotion_plugins_output($id) "$callback¦1¦$language"
      putlog "bMotion: INFO: Output plugin $id ($language) enabled"
      return 0
    }

    #invalid plugin to enable
    putidx $idx "That's not a valid plugin type."
  }


  #disable a plugin
  if [regexp -nocase {disable ([^ ]+) (.+)} $arg matches t id] {
    if {$t == "output"} {
      putidx $idx "Disabling output plugin $id...\r"
      global bMotion_plugins_output
      set details $bMotion_plugins_output($id)
      set blah [split $details "¦"]
      set callback [lindex $blah 0]
      set enabled [lindex $blah 1]
      set language [lindex $blah 2]
      if {$enabled == 0} {
        putidx $idx "... it's already disabled.\r"
        return 0
      }
      set bMotion_plugins_output($id) "$callback¦0¦$language"
      putlog "bMotion: INFO: Output plugin $id disabled"
      return 0
    }

    #invalid plugin to enable
    putidx $idx "That's not a valid plugin type."
  }

  if [regexp -nocase {info ([^ ]+) (.+)} $arg matches t id] {
    set full_array_name_for_upvar "bMotion_plugins_$t"
    upvar #0 $full_array_name_for_upvar TEH_ARRAY
    putidx $idx "plugin details for ${t}:$id = $TEH_ARRAY($id)\n"
    return 0
  }


  #all else fails, list the modules:
  putidx $idx "Installed bMotion plugins:\r"
  putidx $idx "(one moment...)\r"
  set total 0
  foreach t {simple complex output admin action_simple action_complex irc_event } {
    set arrayName "bMotion_plugins_$t"
    upvar #0 $arrayName cheese
    set plugins [array names cheese]
    set plugins [lsort $plugins]
    set a "\002$t\002: "
    set count 0
    foreach n $plugins {
      if {[string length $a] > 55} {
        putidx $idx "$a\r"
        set a "     "
      }
      if {$n != "dummy"} {
      incr count
      incr total
        if {$t == "output"} {
          set details $cheese($n)
          set blah [split $details "¦"]
          set enabled [lindex $blah 1]          
          if {$enabled} {
            append a "$n\[on\], "
          } else {
            append a "$n\[off\], "
          }
        } else {
          append a "$n, "
        }
      }
    }
    set a [string range $a 0 [expr [string length $a] - 3]]
    putidx $idx "$a ($count)\r\n\r"
  }
  putidx $idx "Total plugins: $total\r"
}

# register the plugin
bMotion_plugin_add_admin "plugin" "^plugin" n "bMotion_plugin_admin_plugins" "any"
