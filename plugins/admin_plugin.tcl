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

#register the plugin
bMotion_plugin_add_management "plugin" "^plugin" n "bMotion_plugin_management_plugins" "any"

proc bMotion_plugin_management_plugins { handle { arg "" }} {
  #plugin remove <type> <id>
  if [regexp -nocase {remove ([^ ]+) (.+)} $arg matches t id] {
    bMotion_putadmin "Removing $t plugin $id..."
    set full_array_name_for_upvar "bMotion_plugins_$t"
    upvar #0 $full_array_name_for_upvar TEH_ARRAY
    unset TEH_ARRAY($id)
    bMotion_putadmin "...done."
    return 0
  }

  #enable a plugin
  if [regexp -nocase {enable ([^ ]+) (.+)} $arg matches t id] {
    if {$t == "output"} {
      bMotion_putadmin "Enabling output plugin $id..."
      global bMotion_plugins_output
      set details $bMotion_plugins_output($id)
      set blah [split $details "¦"]
      set callback [lindex $blah 0]
      set enabled [lindex $blah 1]
      set language [lindex $blah 2]
      if {$enabled == 1} {
        bMotion_putadmin "... it's already enabled."
        return 0
      }
      set bMotion_plugins_output($id) "$callback¦1¦$language"
      putlog "bMotion: INFO: Output plugin $id ($language) enabled"
      bMotion_putadmin "...done."
      return 0
    }

    #invalid plugin to enable
    bMotion_putadmin "That's not a valid plugin type."
  }

  #disable a plugin
  if [regexp -nocase {disable ([^ ]+) (.+)} $arg matches t id] {
    if {$t == "output"} {
      bMotion_putadmin "Disabling output plugin $id..."
      global bMotion_plugins_output
      set details $bMotion_plugins_output($id)
      set blah [split $details "¦"]
      set callback [lindex $blah 0]
      set enabled [lindex $blah 1]
      set language [lindex $blah 2]
      if {$enabled == 0} {
        bMotion_putadmin "... it's already disabled."
        return 0
      }
      set bMotion_plugins_output($id) "$callback¦0¦$language"
      putlog "bMotion: INFO: Output plugin $id disabled"
      bMotion_putadmin "...done"
      return 0
    }

    #invalid plugin to enable
    bMotion_putadmin "That's not a valid plugin type."
  }

  if [regexp -nocase {info ([^ ]+) (.+)} $arg matches t id] {
    set full_array_name_for_upvar "bMotion_plugins_$t"
    upvar #0 $full_array_name_for_upvar TEH_ARRAY
    bMotion_putadmin "plugin details for ${t}:$id = $TEH_ARRAY($id)"
    return 0
  }

  #all else fails, list the modules:
  if [regexp -nocase {list( (.+))?} $arg matches what re] {
  set total 0
    if {$re != ""} {
      bMotion_putadmin "Installed bMotion plugins (filtered for '$re'):"
    } else {
      bMotion_putadmin "Installed bMotion plugins:"
    }
    foreach t {simple complex output admin action_simple action_complex irc_event management} {
			set arrayName "bMotion_plugins_$t"
			upvar #0 $arrayName cheese
			set plugins [array names cheese]
			set plugins [lsort $plugins]
			set a "\002$t\002: "
			set count 0
			foreach n $plugins {
				if {($re == "") || [regexp -nocase $re $n]} {
					if {[string length $a] > 55} {
						bMotion_putadmin "$a"
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
			}
			set a [string range $a 0 [expr [string length $a] - 3]]
			if {($re != "") && $count} {
				bMotion_putadmin "$a ($count)\n"
			}
		}
		bMotion_putadmin "Total plugins: $total"
		return 0
	}

  #all else fails, give usage:
  bMotion_putadmin "usage: plugins (list|info|remove|enable|disable)"
  return 0
}
