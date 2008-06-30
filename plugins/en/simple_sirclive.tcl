#
# Modify this to fit your needs :)
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

#                         name  regexp            %  responses
bMotion_plugin_add_simple "wrongsmiley" {^L\($} 60 [list "taunt" "fail" "WORST. SMILEY. EVER." "try realigning your fingers for that one" "E_SMILEY"] "en"

bMotion_plugin_add_simple "bisto" "^ahhh+$" 10 "Bisto!" "en"
bMotion_plugin_add_simple "thinkso" "^(no, )?i do(n't| not) think so" 10 [list "Mr Negative" "I DO think so." "and what would you know?"] "en"
