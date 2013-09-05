#
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

bMotion_plugin_add_complex "nipples" "^i'?m .+$" 20 bMotion_plugin_complex_nipples "en"

proc bMotion_plugin_complex_nipples { nick host handle channel text } {
  if [regexp -nocase {^i'?m ([a-z]+)$} $text matches word] {
		if [bMotion_interbot_me_next $channel] {
	    bMotionDoAction $channel "" "%VAR{nipples}"
			return 1
		}
    return 0
  }
}

bMotion_abstract_register "nippes" {
    "YOU'RE %%? Feel these nipples!"
    "YOU'RE %%? Feel these %VAR{bodypart:plural}"
    "No, *I'm* %%"
}