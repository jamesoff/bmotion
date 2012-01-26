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

bMotion_plugin_add_action_complex "smacks" "^(kiqs|kicks|smacks|twats|injures|beats up|punches|hits|thwaps|slaps|pokes|kills|destroys) %botnicks" 100 bMotion_plugin_complex_action_smacks "en"

proc bMotion_plugin_complex_action_smacks { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "(kicks|smacks|twats|injures|beats up|punches|hits|thwaps|slaps|pokes|kills|destroys) ${botnicks}(('s| in the) (\[a-z \]+))" $text matches 1 2 3 4 where] {
  	if [regexp -nocase "slaps $botnicks around( a bit)? with a( large)? trout" $text] {
  		bMotionDoAction $channel $nick "%VAR{trouts}"
  		return 1
  	}
    bMotionGetSad
    bMotionGetUnLonely
    driftFriendship $nick -5
		if {$where != ""} {
			bMotionDoAction $channel $nick "%VAR{slapped_where}" $where
			bMotion_abstract_add "bodypart" $where
		} else {
			bMotionDoAction $channel $nick "%VAR{slapped}"
		}
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
	"%={ow:arrgh}! my %VAR{bodypart}!%! that was my %VAR{counts} one"
	"%={ow:arrgh} my %VAR{bodypart}! now i only have %NUMBER{50} left"
	"%={ow:arrgh} my %VAR{bodypart}! now i only have %NUMBER{50} left%|look, here in this box"
	"a%REPEAT{3:6:r}gh my %VAR{bodypart}! now i only have %NUMBER{50}%NUMBER{100}%NUMBER{100} left%|look, here in this warehouse"
	"%VAR{frightens}"
}

bMotion_abstract_register "slapped_where" {
	"ow%={: hey}! that was my %VAR{counts} %2 %SMILEY{sad}"
	"ow! my %2 %SMILEY{sad}%! that was my %VAR{counts} one"
	"arrgh! my %2! now i only have %NUMBER{50} left%!%|look, here in this box"
	"arrgh! my %2! now I only have %NUMBER{50}%NUMBER{100}%NUMBER{100} left%|look, here in this warehouse"
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
	"primary"
	"secondary"
	"emergency spare"
	" "
}
