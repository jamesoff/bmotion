#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) Mark Sangster 2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "pings" "^(ping|pong)s? %botnicks" 100 bMotion_plugin_complex_action_pings "en"

proc bMotion_plugin_complex_action_pings { nick host handle channel text } {
	bMotionDoAction $channel $nick "%VAR{pings}"
	bMotionGetUnLonely
	return 1
}

bMotion_abstract_register "pings" {
	"/pings %% in the %VAR{bodypart}"
	"/pongs%|/sprays some deodorant"
	"/pongs"
	"oi that tickles %%"
	"%VAR{sound}"
	"%VAR{goAways}"
}
