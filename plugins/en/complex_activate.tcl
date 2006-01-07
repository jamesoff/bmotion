## bMotion complex plugin: hello
#
# $Id$
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

bMotion_plugin_add_complex "z-activate" "(activate|increase power to)" 100 bMotion_plugin_complex_activate "en"

proc bMotion_plugin_complex_activate { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^(${botnicks}:?,? )?(activate|increase power to) (.+)$" $text matches bot bot2 verb item] {
    if {($bot != "") || ([bMotion_interbot_me_next $channel] && [rand 2])} {
      set item [bMotion_uncolen $item]
      set item [string trim $item]
      if [string match "*." $item] {
        regsub "(.+)\.$" $item {\1} item
      }
      bMotionDoAction $channel $item "%VAR{activateses}"
			return 1
    }
    return 2
  }
}

set activateses {
  "/increases power to %%"
  "/brings %% online"
  "%% engaged%colen"
  "/activates %%"
  "%% to maximum%colen"
}
