# bMotion simple plugins (nl variant)
#
# Modify this to fit your needs :)
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

#                         name  regexp            %  responses
bMotion_plugin_add_simple "huk" "(huk|kek|tilde)" 30 [list "%VAR{huks}"] "nl"
bMotion_plugin_add_simple "kansloos" "kansloos" 40 [list "tonnen d'kansloos!"] "nl"

