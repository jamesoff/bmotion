## bMotion plugin: throwsbot
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

bMotion_plugin_add_action_complex "throwsbot" "^(throws|chucks|lobs|fires|launches|ejects|pushes) %botnicks" 100 bMotion_plugin_complex_action_throwsbot "en"

proc bMotion_plugin_complex_action_throwsbot { nick host handle channel text } {
  if [regexp -nocase "(throws|chucks|lobs|fires|launches|ejects|pushes) $botnicks (at|to|though|out of|out|off|into) (.+)" $text matches verb botn pop target] {
    if [regexp -nocase "^${botnicks}$" $target] {
      #thrown at ourselves o_O
      bMotionDoAction $channel "" "hmm"
      return 1
    }
    bMotionDoAction $channel $target "%VAR{thrownAts}"
    bMotionGetUnLonely
    driftFriendship $nick -1
    return 1
  }
}