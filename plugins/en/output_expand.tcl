#
#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#                          name     callback                       enabled at load (1 = yes) #pri (<=10 = core)
bMotion_plugin_add_output  "expand"   bMotion_plugin_output_expand     1 "en" 20

proc bMotion_plugin_output_expand { channel text } {
	if {[rand 100] > 80} {
		if [regexp -nocase "^\[a-z\]{4,}$" $text] {
			set letters [split $text {}]
			set word [string toupper [lrange $letters 0 0]]
			append word " to the "
			set word2 [join [lrange $letters 1 end] " "]
			append word [string toupper $word2]
			set text $word
		}
	}
	return $text
}

