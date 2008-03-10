#
# Delilah's crap plugin (avec sim-help)
# vim: fdm=indent fdn=1
#
# Altered to new style bMotion_abstract_register/batchadd by Mark Sangster

###############################################################################
# This is a bMotion plugin
# Copyright (C) Delilah's
# Copyright (C) Mark Sangster 2006
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "crap" "^!crap" 100 "bMotion_plugin_complex_crap" "en"

proc bMotion_plugin_complex_crap { nick host handle channel text } {
	if {![bMotion_interbot_me_next $channel]} {
		bMotionDoAction $channel $nick "%VAR{random_crap_main}"
		return 1
	}
}

bMotion_abstract_register "random_crap_main" {
	"/does a %VAR{random_crap_adj} %VAR{random_crap_type} and hands it to %ruser{enemy}"
	"/crimps off a %VAR{random_crap_adj} %VAR{random_crap_type} and hands it to %ruser{enemy}"
}

bMotion_abstract_register "random_crap_adj"
bMotion_abstract_batchadd "random_crap_adj" {
         "lemon-flavoured"
         "tasty"
				 "%VAR{colours}"
				 "delicious"
				 "yummy"
  }
  
bMotion_abstract_register "random_crap_type"
bMotion_abstract_batchadd "random_crap_type" {
         "poop"
         "crap"
         "shit"
         "dingleberry"
         "dollop"
				 "poo"
  }

