## bMotion complex plugin: hello
#
# $Id: complex_hello.tcl 773 2007-02-28 08:43:49Z james $
#
# vim: fdm=indent fdn=1

###############################################################################
# This is not just a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "mands" "(this is|these are) not just (.+)" 100 bMotion_plugin_complex_mands "en"

proc bMotion_plugin_complex_mands { nick host handle channel text } {
  global botnicks

	if {![bMotion_interbot_me_next $channel]} {
		return 0
	}

	if [regexp -nocase "(this is|these are) not just (.+)" $text matches first second] {
		if [regexp -nocase "(this is|these are)" $second] {
			# they've already made the joke
			return 0
		}
		# TODO: check if we need to move "a" around or anything
		if [regexp -nocase "(an|some) (.+)" $second matches pre post] {
			set second "$post"
			append pre " "
		} else {
			set pre ""
		}
		bMotionDoAction $channel $second "... $first ${pre}%VAR{mands_pre} %% %VAR{mands}"
		return 1
	}
	return 0
}

bMotion_abstract_register "mands_pre" {
	"premium"
	"prime"
	"traditionally cured"
	"hand-prepared"
	"lincolnshire"
	"golden roast"
	"connoisseur"
	"finest"
	"best"
}

bMotion_abstract_register "mands" {
	"drizzled with %VAR{mands_sauce}"
	"sprinkled with %VAR{mands_sprinkle}"
	"covered with %VAR{mands_cover}"
	"with stain digestors and superior performance at 30 degrees"
	}

bMotion_abstract_register "mands_sauce" {
	"cranberry sauce"
	"creamy mustard and dill sauce"
	"red wine and twany port sauce"
	"%VAR{food}"
}

bMotion_abstract_register "mands_sprinkle" {
	"inexplicably expensive salt%|i mean, what the fuck? salt is salt!%|/grumbles"
	"italian parmesan cheese"
	"some sort of nut%|(may contain nuts)"
	"some sort of nut"
	"%VAR{food}"
	"fish and chips"
}

bMotion_abstract_register "mands_cover" {
	"some sort of very expensive cheese"
	"butter"
	"lard"
	"%VAR{food}"
}
