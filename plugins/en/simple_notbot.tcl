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

bMotion_plugin_add_simple "notbot" "%botnicks('s| is) a bot" 60 "%VAR{notbots}" "en"

bMotion_plugin_add_simple "arebot" "((is %botnicks a bot)|(are you a bot,? %botnicks)|(^%botnicks%:? are you a bot))" 60 "%VAR{nos}" "en"

bMotion_abstract_register "notbots"
bMotion_abstract_batchadd "notbots" {
  "no I'm not"
  "am not :("
  "am not"
  "LIES."
  "SILENCE%colen"
  "LIES, ALL LIES%|unless a witness steps forward"
  "/smacks %%%|shut up"
  "shh%|sekrit"
}
