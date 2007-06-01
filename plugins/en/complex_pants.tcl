## bMotion complex plugin: hate_pants
#
# $Id: $
#
# vim:set fdm=indent fdn=1:

###############################################################################
# This is a bMotion plugin
#
# Copyright (C) Mark Sangster 2007
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
#
###############################################################################

bMotion_plugin_add_complex "complex_hate_pants" "i hate (your|those)" 100 bMotion_plugin_complex_hate_pants "en"

proc bMotion_plugin_complex_hate_pants { nick host handle channel text } {
	global botnicks
	if [regexp -nocase "^(${botnicks}:?,? )?i hate (your|those) (.+)$" $text matches bot bot2 verb item] {
		if {($bot != "") || ([bMotion_interbot_me_next $channel] && [rand 2])} {
			set item [bMotion_uncolen $item]
			set item [string trim $item]
			if [string match "*." $item] {
				regsub "(.+)\.$" $item {\1} item
			}
			bMotionDoAction $channel $item "%VAR{hateitem}"
			return 1
		}
		return 2
	}
}

bMotion_abstract_register "hateitem"
bMotion_abstract_batchadd "hateitem" {
  "so, i hate your %% too"
  "yeah me too, %ruser gave them to me and i've never liked them"
  "what are you trying to say?"
  "/activates death ray"
  "maybe if %% was %VAR{colours}"
  "%VAR{randomZimness}"
}
