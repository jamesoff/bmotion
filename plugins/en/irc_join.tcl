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


proc bMotion_plugins_irc_default_join { nick host handle channel text } { 

  #has something happened since we last greeted?
  set lasttalk [bMotion_plugins_settings_get "system:join" "lasttalk" $channel ""]

  #if 1, we greeted someone last
  #if 0, someone has said something since
  if {$lasttalk == 1} {
    bMotion_putloglev 2 d "dropping greeting for $nick on $channel because it's too idle"
    return 0
  }

  global botnick mood
  set chance [rand 10]
  set greetings [bMotion_abstract_all "ranjoins"]
  if {$handle != "*"} {
    set greetings [concat $greetings [bMotion_abstract_all "bigranjoins"]]
    set greetings [concat $greetings [bMotion_abstract_all "insult_joins"]]
    if {$nick == $bMotionCache(lastLeft)} {
      set greetings [bMotion_abstract_all "welcomeBacks"]
      set bMotionCache(lastLeft) ""
    }
    incr mood(happy)
    incr mood(lonely) -1
  }

  #set nick [bMotion_cleanNick $nick $handle]

  bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $greetings]
  set bMotionCache(lastGreeted) $nick
  bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 1

  return 0
}

bMotion_plugin_add_irc_event "default join" "join" ".*" 75 "bMotion_plugins_irc_default_join" "en"

bMotion_abstract_register "insult_joins"
bMotion_abstract_batchadd "insult_joins" [list "%ruser: yeah, %% does suckOH HI %%!" "\[%%\] I'm a %VAR{PROM}%|%VAR{wrong_infoline}" "\[%%\] I love %ruser%|%VAR{wrong_infoline}"]

bMotion_abstract_register "wrong_infoline"
bMotion_abstract_batchadd "wrong_infoline" [list "oops, wrong infoline, sorry" "huk, wrong infoline" "whoops" "o wait not that infoline"]