# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


proc bMotion_plugins_irc_default_quit { nick host handle channel text } { 

  #has something happened since we last spoke?
  set lasttalk [bMotion_plugins_settings_get "system:join" "lasttalk" $channel ""]

  #if 1, we greeted someone last
  #if 0, someone has said something since
  if {$lasttalk == 1} {
    bMotion_putloglev 2 d "dropping depart for $nick on $channel because it's too idle"
    return 0
  }

  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{departs}"
  set bMotionCache(lastGreeted) $nick
  bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 1

  return 0
}

bMotion_plugin_add_irc_event "default quit" "quit" ".*" 40 "bMotion_plugins_irc_default_quit" "en"
bMotion_plugin_add_irc_event "default part" "part" ".*" 40 "bMotion_plugins_irc_default_quit" "en"

bMotion_abstract_register "departs"
bMotion_abstract_batchadd "departs" [list "what a strange person" "i'm going to miss them" "nooo! come back! %VAR{unsmiles}" "hey! I was talking to you!" "what a nice man"]
