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

bMotion_plugin_add_action_complex "hides" "^hides behind %botnicks" 90 bMotion_plugin_complex_action_hides "en"

proc bMotion_plugin_complex_action_hides { nick host handle channel text } {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{hiddenBehinds}"
    bMotionGetUnLonely
    bMotionGetHappy
    return 1
}
