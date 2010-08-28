#
# vim: fdm=indent fdn=1
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# appends random stuff to the output; evolved from the gollum plugin by Kev

proc bMotion_plugin_output_append { channel line } {
	set length [string length $line]
	set n [rand 100]
	bMotion_putloglev d * "output_append: length=$length, n=$n"
	if {($length > 10) && ($n > 90)} {
		bMotion_putloglev d * "output_append: doing!"
		set line [string trim $line]
		# make sure the line ends with a letter (other than D)
		# this is so we don't make ourselves look dumb(er) by adding
		# on the end of a line with a smiley
		if [rand 2] {
			if [regexp -nocase {[a-ce-z]$} $line] {
				append line "%VAR{appends}"
			} else {
				bMotion_putloglev d * "output_append: not appending to this line as it may end in a smiley"
			}
		} else {
			if {![regexp {^[:;=/]} $line]} {
				# don't do this for /me type lines and smilies
				return $line
			}
			set line "%VAR{prepends} $line"
		}
		bMotion_putloglev d * "output_append: preprocessed line is $line"

		set line [bMotion_process_macros $channel $line]
		regsub -all "%space" $line " " line

		bMotion_putloglev d * "output_append: postprocessed line is $line"
	}
	return $line
}

bMotion_abstract_register "preciouses" {
	" my precious"
	" precious"
	" preciouses"
	" the precious"
}

bMotion_abstract_register "appendslist" {
	", in accordance with the prophecy"
	", in accordance with my master's thesis on the Legend of Zelda"
	"%spaceand you're sitting in it right now"
	"%spacebut it's nothing sexual"
	". In my pants"
	". you poof!"
	"%space\[citation needed\]"
	"%spacebut that's just one bot's opinion"
	"%spacebut what would I know"
	", i think"
	"%spaceor something totally different perhaps"
	"%spacein the butt"
	"%spacein a vagina"
}
bMotion_abstract_add_filter "appendslist" "^ "

bMotion_abstract_register "narfs" {
  " zort!"
  " narf"
  " poit."
  " poit!"
  " narf!"
}

bMotion_abstract_register "appends" {
	"%VAR{preciouses}"
	"%VAR{appendslist}"
	"%VAR{narfs}"
}

bMotion_abstract_register "prepends" {
  "basically,"
  "well,"
  "so, like,"
	"r"
}

# delete old preciouses contents if it exists
# actually, this might not be needed, but just in case :)
bMotion_abstract_add_filter "preciouses" {^[^ ]}
bMotion_abstract_add_filter "narfs" {^[^ ]}

bMotion_plugin_add_output "append" bMotion_plugin_output_append 1 "en" 11
