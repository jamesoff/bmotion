# bMotion simple action plugin squeeze
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

#                         name  regexp            %   responses
bMotion_plugin_add_action_simple "squeeze" "^(squeezes|beeps|honks|knijpt( in)?) %botnicks" 100 "%VAR{honks}" "en"

bMotion_abstract_register "honks"
bMotion_abstract_batchadd "honks" {
  "/honks"
  "/beeps"
  "beep beep"
  "honk honk"
}
