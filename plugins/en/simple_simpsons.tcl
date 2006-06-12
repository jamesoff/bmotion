# bMotion simple plugins
#
# Modify this to fit your needs :)
#
# $Id: simple_general.tcl 624 2005-08-14 00:41:55Z notopic $
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
bMotion_plugin_add_simple "lisabraces" {^[^ ]+ needs braces!*} 100 [list "dental plan!"] "en"

