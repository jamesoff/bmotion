## bMotion plugin: not a bot
#
# $Id: simple_commaeight.tcl,v 1.0 2006/12/27 21:51:24 gloin Exp $
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) Mike Ely 2006
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_simple "commaeight" {"\*",8,1} 60 "%VAR{loadingready}" "en"

set loadingready {
   "SEARCHING FOR *%|LOADING%|READY."
   }
