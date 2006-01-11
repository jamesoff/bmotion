# bMotion: admin plugin file for logging
#
# $Id: admin_flood.tcl 655 2006-01-01 13:08:32Z james $
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

proc bMotion_plugin_management_log { handle { arg "" } } {
  global bMotion_log_regexp

	if [regexp -nocase {set (.+)} $arg matches log_re] {
		set bMotion_log_regexp $log_re
		bMotion_putadmin "bMotion: log filter set to /$log_re/"
		return 0
	}

	bMotion_putadmin "bMotion: log filter is currently: /$bMotion_log_regexp/"
	bMotion_putadmin "bMotion: .bmotion log set <regexp> to set"
	return 0
}

bMotion_plugin_add_management "log" "^log" n "bMotion_plugin_management_log"
