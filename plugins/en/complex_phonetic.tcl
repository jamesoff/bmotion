# $Id$
#
# simsea's "asshat" phonetic plugin

###############################################################################
# This is a bMotion plugin
# Copyright (C) Andrew Payne 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# phonetic transforms - the first one should always be the "modemn" real one
# the second one is the WW2, but that's just for reference
set phonetic_xforms(a) { "alpha" "able" "asshat" "aardvark" "armadillo" "anthill" }
set phonetic_xforms(b) { "beta" "baker" "bonanza" "bart" "bling" }
set phonetic_xforms(c) { "charlie" "charlie" "colen" "caboose" "crater" "crickey" }
set phonetic_xforms(d) { "delta" "dog" "dirty" "dildo" }
set phonetic_xforms(e) { "echo" "easy" "englebert" }
set phonetic_xforms(f) { "foxtrot" "fox" "fast" }
set phonetic_xforms(g) { "golf" "george" "gravy" }
set phonetic_xforms(h) { "hotel" "howv" "harry"}
set phonetic_xforms(i) { "india" "inter" "idiot" "incompetent" }
set phonetic_xforms(j) { "juliet" "jig" "jargon" "jingle" "j00st"}
set phonetic_xforms(k) { "kilo" "king" "killer" "kong" }
set phonetic_xforms(l) { "lima" "love" "little" "lingo" }
set phonetic_xforms(m) { "mike" "mike" "martin" "miopic" "micro" }
set phonetic_xforms(n) { "november" "nan" "ninny" "needle"}
set phonetic_xforms(o) { "oscar" "oboe" "ovary" }
set phonetic_xforms(p) { "papa" "peter" "please" "piglet" "pole" }
set phonetic_xforms(q) { "quebec" "queen" "quit" "quilt" "quixotic"}
set phonetic_xforms(r) { "romeo" "roger" "ribbed" "ride" }
set phonetic_xforms(s) { "sierra" "sugar" "slimy" "sleek" }
set phonetic_xforms(t) { "tango" "tare" "tweek" "tilde" }
set phonetic_xforms(u) { "uniform" "uncle" "ubiquitous" "useless" }
set phonetic_xforms(v) { "victor" "victor" "visitor" "vericose" "vary" }
set phonetic_xforms(w) { "whiskey" "william" "wibble" "wonky" }
set phonetic_xforms(x) { "x-ray" "x-ray" "xylophone" }
set phonetic_xforms(y) { "yankee" "yolk" "yes" "yellow" }
set phonetic_xforms(z) { "zulu" "zebra" "zephyr" }
set phonetic_xforms(0) { "zero" }
set phonetic_xforms(1) { "one" }
set phonetic_xforms(2) { "two" }
set phonetic_xforms(3) { "three" }
set phonetic_xforms(4) { "four" }
set phonetic_xforms(5) { "five" }
set phonetic_xforms(6) { "six" }
set phonetic_xforms(7) { "seven" }
set phonetic_xforms(8) { "eight" }
set phonetic_xforms(9) { "niner" }

# bMotion_plugin_complex_phonetic_xform procedure
# this is the logic of the whole yelling out phonetic "simplification"
# of words. there are two styles. value 0 will do proper modern versions
# and value 1 will do as it pleases :-P
proc bMotion_plugin_complex_phonetic_xform { text style } {
	global phonetic_xforms

	set line ""
	set letters [ split [ string tolower $text ] {} ]

	# check for the action delimeter
	set action 0
	if { [ regexp -nocase "^/" $text ] } {
		set action 1
	}
	
	# go through all the letters
	foreach letter $letters {
		if { [ regexp -nocase {[A-Za-z0-9]} $letter ] } {
			if { $style == 0 } {
				set newChar [ lindex $phonetic_xforms($letter) 0 ]
				set line "$line$newChar "
			} elseif { $style == 1 } {
		 		set newChar [ pickRandom $phonetic_xforms($letter) ]
				set line "$line$newChar "
			} else {
				bMotion_putloglev d * "bMotion: (phonetic) did not get a style that makes sense"
				return ""
			}
		} elseif { $letter == " " } {
			set line "$line "
		} 
	}

	# are we yelling?
	if { [ rand 2 ] } {
		set line [ string toupper $line ]
	}

	# put the action delimeter back
	if { $action } {
		set line "/$line"
	}

	return $line 
}
# end bMotion_plugin_complex_phonetic_xform

# bMotion_plugin_complex_phonetic procedure
# callback for the bmotion plugin
proc bMotion_plugin_complex_phonetic { nick host handle channel text } {
	# JamesOff says that if I don't do this, then bMotion will start ignoring
	# people rather quickly. So... I did it
	bMotion_flood_undo $nick

	# remove the leading command
	regexp -nocase "^!(asshat|phonetic) (.+)" $text matches command text
	
	set style 0
	if { $command == "asshat" } {
		set style 1
	}

	# phonetic the line
	set line [ bMotion_plugin_complex_phonetic_xform $text $style ]

	# print out the reply
	if { $line != "" } {
		puthelp "PRIVMSG $channel :$line"
		bMotion_putloglev d * "bMotion: (phonetic:$command) $nick needed it spelled out, so I did"
	}
}
# end bMotion_plugin_complex_phonetic

#  bMotion_plugin_output_asshat procedure
# make the phonetic asshat plugin a general output filter
proc bMotion_plugin_output_asshat { channel text } { 
	return [ bMotion_plugin_complex_phonetic_xform $text 1 ]
}
# end bMotion_plugin_output_asshat

#  bMotion_plugin_output_phonetic procedure
# make the phonetic plugin a general output filter
proc bMotion_plugin_output_phonetic { channel text } { 
	return [ bMotion_plugin_complex_phonetic_xform $text 0 ]
}
# end bMotion_plugin_output_phonetic


# register callbacks
bMotion_plugin_add_complex "phonetic" "^!phonetic|^!asshat" 100 "bMotion_plugin_complex_phonetic" "en"
bMotion_plugin_add_output "asshat" bMotion_plugin_output_asshat 0 "en"
bMotion_plugin_add_output "phonetic" bMotion_plugin_output_phonetic 0 "en"
