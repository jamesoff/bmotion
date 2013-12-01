#
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

bMotion_abstract_register "loadingready" {
   "SEARCHING FOR *%|LOADING%|READY."
 }
