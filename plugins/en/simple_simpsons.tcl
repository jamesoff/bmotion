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
bMotion_plugin_add_simple "lisabraces" {^[^ ]+ needs braces!*} 100 [list "dental plan!"] "en"
bMotion_plugin_add_simple "bingo" {bingo} 100 [list "you just sunk my battleship"] "en"
