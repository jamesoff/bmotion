# bMotion admin help
#
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

#                        name   regexp               flags   callback
bMotion_plugin_add_management "help" "^help"     t       "bMotion_plugin_management_help" "any"

#################################################################################################################################
# Declare plugin functions

proc bMotion_plugin_management_help { handle { args "" } } {
  global bMotion_plugins_management

  if {$args == ""} {
	bMotion_putadmin "You can run bMotion commands from DCC with .bmotion COMMAND,"
	bMotion_putadmin "  from a channel with .bmotion BOTNICK COMMAND, and from a"
	bMotion_putadmin "  query with the bot with .bmotion COMMAND."
  bMotion_putadmin "Loaded bMotion Admin Commands:"
  set line ""
  foreach plugin $bMotion_plugins_management {
  	append line "$plugin "
  	if {[string length $line] > 50} {
  		bMotion_putadmin "  $line"
  		set line ""
  	}
  }
  if {$line != ""} {
  	bMotion_putadmin "  $line"
  }

  bMotion_putadmin "Help is available for some plugis; run .bmotion help COMMAND"
  bMotion_putadmin "  for more information."
  return 1
  } else {
  	switch $arg {
  		default {
  			bMotion_putadmin "I seem to have misplaced my help for that command."
  		}
  	}
  	return 1
  }
}
