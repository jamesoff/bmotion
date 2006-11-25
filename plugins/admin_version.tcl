# bMotion: admin plugin file for version info
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


proc bMotion_plugin_management_version { handle { arg "" } } {
  global bMotionVersion

	bMotion_putadmin "bMotion $bMotionVersion -- http://www.bmotion.net"

  return 0
}

bMotion_plugin_add_management "version" "^version" n "bMotion_plugin_management_version"
