## bMotion plugin: smacks
#
# $Id$

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "smacks" "^(kicks|smacks|twats|injures|beats up|punches|hits|thwaps|slaps|pokes|kills|destroys) %botnicks" 100 bMotion_plugin_complex_action_smacks "en"

proc bMotion_plugin_complex_action_smacks { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "(kicks|smacks|twats|injures|beats up|punches|hits|thwaps|slaps|pokes|kills|destroys) ${botnicks}" $text] {
  	if [regexp -nocase "slaps $botnicks around( a bit)? with a( large)? trout" $text] {
  		bMotionDoAction $channel $nick "%VAR{trouts}"
  		return 1
  	}
    bMotionGetSad
    bMotionGetUnLonely
    driftFriendship $nick -2
    bMotionDoAction $channel $nick "%VAR{slapped}"
    return 1
  }
}

bMotion_abstract_register "trouts"
bMotion_abstract_batchadd "trouts" {
	"/slaps %% back using a default menu command"
	"%VAR{goAways}"
	"omg n00b"
	"omg noob"
	"n00b"
	"%VAR{goAways} noob"
}

bMotion_abstract_register "slapped"
bMotion_abstract_batchadd "slapped" {
	"ow hey! that was my %VAR{counts} %VAR{bodypart} %VAR{unsmiles}"
	"ow! that was my %VAR{counts} %VAR{bodypart} %VAR{unsmiles}"
	"they took my squeezing arm!%|WHY MY SQUEEZING ARM?!?%|WHHHYYYYY?"
	"/%VAR{smacks} %% back with %VAR{sillyThings}"
	"/%VAR{smacks} %% back with %ruser"
	"ow! my %VAR{bodypart}!"
	"ow! my %VAR{bodypart}! that was my %VAR{counts} one"
	"arrgh my %VAR{bodypart}! now i only have %NUMBER{50} left"
	"arrgh my %VAR{bodypart}! now i only have %NUMBER{50} left%|look, here in this box"
	"%VAR{frightens}"
}

bMotion_abstract_register "counts"
bMotion_abstract_batchadd "counts" {
	"last"
	"penultimate"
	"2nd-to-last"
	"only"
	"backup"
	"spare"
	"most important"
	"least relavant"
}
