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

bMotion_plugin_add_complex "z-activate" "(enable|activate|increase power to)" 100 bMotion_plugin_complex_activate "en"

proc bMotion_plugin_complex_activate { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^(${botnicks}:?,? )?(enable|activate|increase power to) (.+)$" $text matches bot bot2 verb item] {
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

bMotion_abstract_register "activateses"
bMotion_abstract_batchadd "activateses" {
  "/increases power to %%"
  "/brings %% online"
  "%% engaged%colen"
  "/activates %%"
  "%% to maximum%colen"
}
