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


bMotion_plugin_add_irc_event "default join" "join" ".*" 80 "bMotion_plugins_irc_deafult_join" "en"

proc bMotion_plugins_irc_deafult_join { nick host handle channel text } { 

  #has something happened since we last greeted?
  set lasttalk [bMotion_plugins_settings_get "system:join" "lasttalk" $channel ""]

  #if 1, we greeted someone last
  #if 0, someone has said something since
  if {$lasttalk == 1} {
    bMotion_putloglev 2 d "dropping greeting for $nick on $channel because it's too idle"
    return 0
  }

  global ranjoins bigranjoins botnick mood
  set chance [rand 10]
  set greetings $ranjoins
  if {$chance > 8} {
    if [matchattr $handle I] {
      set greetings [concat $greetings $bigranjoins]
      if {$nick == $bMotionCache(lastLeft)} {
        set greetings $welcomeBacks
        set bMotionCache(lastLeft) ""
      }
      incr mood(happy)
      incr mood(lonely) -1
    }

    #set nick [bMotion_cleanNick $nick $handle]

    bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $greetings]
    set bMotionCache(lastGreeted) $nick
    bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 1
  }

  return 0
}

