#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_simple "notlong" "not ((very|that|too) )?long" 20 [list "%VAR{notlong}"] "en"

# do this so that female bots won't say anything
bMotion_abstract_register "notlong_male" {
	"if you think that's short, you should see my penis"
}

bMotion_abstract_register "notlong" 
