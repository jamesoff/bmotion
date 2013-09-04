#
# vim: fdm=indent fdn=1

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
	if [bMotion_interbot_me_next $channel] {
		bMotionDoAction $channel $nick "%VAR{random_crap_main}"
		return 1
	}
}

bMotion_abstract_register "random_crap_main" {
	"/does a %VAR{random_crap_adj} %VAR{random_crap_type} and hands it to %ruser{enemy}"
	"/does a %VAR{random_crap_adj} %VAR{random_crap_type} and hands it to %ruser{enemy}%|present!"
	"/crimps off a %VAR{random_crap_adj} %VAR{random_crap_type} and hands it to %ruser{enemy}"
	"/crimps off a %VAR{random_crap_adj} %VAR{random_crap_type} and hands it to %ruser{enemy}%|present"
	"/gift wraps a %VAR{random_crap_adj} %VAR{random_crap_type}%|/ships it first class to %ruser{enemy}"
	"/injects a %VAR{random_crap_adj} %VAR{random_crap_type} into a padded envelope and posts it to %ruser{enemy}"
	"/does a %VAR{random_crap_adj} %VAR{random_crap_type} in a flan base%|/cooks it%|Here you go, %ruser{enemy}, I made you this flan!"
}
bMotion_abstract_add_filter "random_crap_main" "\$ruser"
bMotion_abstract_add_filter "random_crap_main" "\$\|"

bMotion_abstract_register "random_crap_adj" {
         "lemon-flavoured"
         "tasty"
				 "%VAR{colours}"
				 "delicious"
				 "yummy"
  }

bMotion_abstract_register "random_crap_type" {
         "poop"
         "crap"
         "shit"
         "dingleberry"
         "dollop"
				 "poo"
  }

bMotion_abstract_add "randomStuff" {
	"%VAR{random_crap_main}"
}
