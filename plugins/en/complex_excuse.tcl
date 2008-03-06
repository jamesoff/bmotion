# $Id: complex_sport.tcl 753 2007-01-02 22:27:32Z james $
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "excuse" "^!excuse" 100 bMotion_plugin_complex_excuse "en"

proc bMotion_plugin_complex_excuse { nick host handle channel text } {
	if [bMotion_interbot_me_next $channel] {
		bMotionDoAction $channel "" "%VAR{excuse_wrapper}"
		return 1
	}
	return 0
}

bMotion_abstract_register "excuses" {
	"%VAR{excuse_verbs} %VAR{excuse_people} %VAR{excuse_nouns}"
}

bMotion_abstract_register "excuse_people" {
	"my"
	"%OWNER{%ruser}"
	"my landlord's"
	"the"
	"my friend's"
	"my neighbour's"
	"the president's" "the Queen's"
	"the traffic warden's"
	"my solicitor's"
	"my lawyer's"
	"the Prime-Minister's"
	"the President's"
}

bMotion_abstract_register "excuse_nouns" {
	"%VAR{dNouns}"
	"rug"
	"daughter"
	"goldfish"
	"cat"
	"car"
	"moose"
	"light bulb"
	"curtains"
	"kite"
	"monkey"
	"mongoose"
	"monitor"
	"theme park"
	"girlfriend"
	"parents" "tractor" "combine harvester" "boyfriend" "lover"
	"mistress" "goat"
	"Illegal MP3 collection"
	"TV"
	"Webcam"
	"Crystal Ball"
	"Helmet"
	"Headphones"
	"Stereo"
	"Windows"
	"Front Door"
	"Motorbike"
	"Mouse"
	"PDA"
	"Hedge"
	"Garden"
	"Bush"
	"Ticket"
	"Pants"
	"Trousers"
	"Trainers"
	"Bicycle-pump"
	"Football"
	"Scrabble"
	"Jenga Blocks"
	"fridge"
}

bMotion_abstract_register "excuse_verbs" {
	"%VAR{dVerbs}"
	"shampoo"
	"iron"
	"fly"
	"wash"
	"observe"
	"admire"
	"nail"
	"hammer"
	"screw"
	"hang"
	"shower"
	"explode"
	"clean up"
	"polish"
	"kick"
	"punch"
	"repair"
	"visit"
	"taunt"
	"consume"
	"reprogram"
	"dismantle"
	"reconstruct"
	"recharge"
	"neuter"
	"mount"
	"prune"
	"cook"
	"hide"
	"steal"
	"polish"
	"mow"
	"tear up"
	"burn"
	"ignite"
	"cleanse"
	"insure"
	"MOT"
	"tax"
}

bMotion_abstract_register "excuse_wrapper" {
	"I can't, I've got to %VAR{excuses}"
	"Sorry, I had to %VAR{excuses}"
	"Sorry, I need to %VAR{excuses}"
	"Sorry I'm late, I had to %VAR{excuses}"
}

