## bMotion plugin: nn
#
# $Id: simple_hnn.tcl 663 2006-01-11 20:46:46Z james $
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_simple "nn" "(nn|gn|nite|night|nite ?nite),? (%botnicks|all)!*$" 100 [list "nn %VAR{unsmiles}" "nn" "nite" "night" "nn %%" "sleep well" "sweet dreams"] en

