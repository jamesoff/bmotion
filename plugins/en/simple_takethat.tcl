## bMotion simple plugin: take that
#
# $Id: simple_sneeze.tcl 439 2004-03-17 20:36:24Z jamesoff $
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_simple "takethat" "^take that!*$" 60 [list "and party!" "and party"] "en"

