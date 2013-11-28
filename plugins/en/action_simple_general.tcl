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
#bMotion_plugin_add_action_simple "licks" "(licks|bites) %botnicks" 100 [list "%VAR{rarrs}"]
bMotion_plugin_add_action_simple "moo-action" "^(goes |does a )?moo+s?( at %botnicks)?" 40 [list "%VAR{moos}"] "en"

bMotion_plugin_add_action_simple "calls" "calls %botnicks \[a-z\]" 100 [list "r" "%VAR{smiles}" "well slap my ass and call me that thing you said!" "that's not my name!"] "en"

bMotion_plugin_add_action_simple "finger" "pulls %botnicks's? finger" 100 [list "%VAR{sound_short}"] "en"
bMotion_plugin_add_action_simple "rootkit" "rootkits %botnicks" 100 [list "%SMILEY{sad}" "%me#"] "en"
