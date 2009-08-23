# vim: fdm=indent fdn=1
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, %OWNER

proc bMotion_plugin_output_OWNER { channel line } {

	if {[regexp -nocase "%OWNER\{(.*?)\}" $line matches BOOM]} {
		set BOOM [string map {\\ \\\\ [ \\\[ ] \\\] \{ \\\{ \} \\\} $ \\\$ \" \\\" | \\\|} $BOOM]

		# set line [bMotionInsertString $line "%OWNER\{$BOOM\}" [bMotionMakePossessive $BOOM]]
		regsub -nocase "%OWNER\{$BOOM\}" $line [bMotionMakePossessive $BOOM] line
		regsub -all "\\\\" $line "" line
	}
	return $line
}

bMotion_plugin_add_output "OWNER" bMotion_plugin_output_OWNER 1 "en" 5
