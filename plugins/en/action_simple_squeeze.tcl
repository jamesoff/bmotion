#
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#                         name  regexp            %   responses
bMotion_plugin_add_action_simple "squeeze" "^(squeezes|beeps|honks|knijpt( in)?) %botnicks" 100 "%VAR{honks}" "en"

bMotion_abstract_register "honks" {
  "/honks"
  "/beeps"
  "beep beep"
  "honk honk"
}
