# $Id$
#
# Delilah's crap plugin (avec sim-help)

set random_crap_adj {
	"blue"
	"yellow"
	"lemon-flavoured"
	"monstar"
	"shiny"
	"tall"
	"furry"
	"loud"
	"warm"
	"stinky"
	"tasty"
}

set random_crap_type {
	"poop"
	"crap"
	"shit"
	"turd"
	"log"
	"dropping"
	"doodoo"
	"dudu"
	"poo"
	"number 2"
	"dump"
	"klingon"
	"dingleberry"
	"dollop"
}

proc bMotion_plugin_complex_crap { nick host handle channel text } {
	#bMotion_flood_undo $nick

	# regexp -nocase "^!crap (.+)" $text matches command text

	bMotion_putloglev d * "bMotion: i have been made all crappy by $nick"

	global random_crap_adj random_crap_type
	set adj [ pickRandom $random_crap_adj ]
	set type [ pickRandom $random_crap_type ]

	set phrase "/does a $adj $type and hands it to %ruser"
	bMotionDoAction $channel $nick $phrase
}

# register callbacks
bMotion_plugin_add_complex "crap" "^!crap" 100 "bMotion_plugin_complex_crap" "en"

