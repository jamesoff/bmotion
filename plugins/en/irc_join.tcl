# $Id$
#
# vim: fdm=indent fdn=1

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

	#we must also see if we're next to greet
	if {![bMotion_interbot_me_next $channel]} {
		return 1
	}
	
  global botnick mood
  set chance [rand 10]

  set greetings [bMotion_abstract_all "ranjoins"]
	set lastLeft [bMotion_plugins_settings_get "system:join" "lastleft" $channel ""]
	
	if {$handle != "*"} {
    if {![rand 10]} {
      set greetings [concat $greetings [bMotion_abstract_all "insult_joins"]]
    }
    if {$nick == $lastLeft} {
      set greetings [bMotion_abstract_all "welcomeBacks"]
      bMotion_plugins_settings_set "system:join" "lastleft" $channel "" ""
    }
    bMotionGetHappy
    bMotionGetUnLonely
  } else {
    #don't greet people we don't know
    if {[bMotion_setting_get "friendly"] != 1} {
      return 0
    }
  }

  #set nick [bMotion_cleanNick $nick $handle]
  if {[getFriendship $nick] < 30} {
    set greetings [bMotion_abstract_all "dislike_joins"]
  }

  if {[getFriendship $nick] > 75} {
    set greetings [concat $greetings [bMotion_abstract_all "bigranjoins"]]
  }

  bMotionDoAction $channel [bMotionGetRealName $nick $host] [pickRandom $greetings]
  bMotion_plugins_settings_set "system:join" "lastgreeted" $channel "" $nick
  bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 1

  return 1
}

bMotion_plugin_add_irc_event "default join" "join" ".*" 40 "bMotion_plugins_irc_default_join" "en"

bMotion_abstract_register "insult_joins"
bMotion_abstract_batchadd "insult_joins" [list "%ruser: yeah, %% does suckOH HI %%!" "\[%%\] I'm a %VAR{PROM}%|%VAR{wrong_infoline}" "\[%%\] I love %ruser%|%VAR{wrong_infoline}" "/looks at %%%|so THAT'S where my oil-skin thong got to!"]

bMotion_abstract_register "wrong_infoline"
bMotion_abstract_batchadd "wrong_infoline" [list "oops, wrong infoline, sorry" "huk, wrong infoline" "whoops" "o wait not that infoline"]

bMotion_abstract_register "dislike_joins"
bMotion_abstract_batchadd "dislike_joins" [list "shut up" "o no it's %%" "oh no it's %%" "oh noes it's %% %VAR{unsmiles}"]
bMot
