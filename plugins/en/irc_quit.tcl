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


proc bMotion_plugins_irc_default_quit { nick host handle channel text } { 

  #has something happened since we last spoke?
  set lasttalk [bMotion_plugins_settings_get "system:join" "lasttalk" $channel ""]

  if {$handle == "*"} {
    if {[bMotion_setting_get "friendly"] != 1} {
      return 0
    }
  }
  
  if {[bMotionIsFriend $nick]} {
  	set output "%VAR{departs-nice}"
  } else {
  	set output "%VAR{departs-nasty}"
  }
  

  #don't do anything if it looks like an error
  if [regexp -nocase "(irc\.|error|reset|timeout|closed)" $text] {
    return 0
  }

  #if 1, we greeted someone last
  #if 0, someone has said something since
  if {$lasttalk == 1} {
    #bMotion_putloglev 2 d "dropping depart for $nick on $channel because it's too idle"
    putlog "dropping depart for $nick on $channel because it's too idle"
    return 0
  }

  bMotionDoAction $channel [bMotionGetRealName $nick $host] $output
  bMotion_plugins_settings_set "system:join" "lasttalk" $channel "" 1
	bMotion_plugins_settings_set "system:join" "lastleft" $channel "" $nick
	bMotion_plugins_settings_set "system:join" "lastgreeted" $channel "" $nick

  return 1
}

bMotion_plugin_add_irc_event "default quit" "quit" ".*" 15 "bMotion_plugins_irc_default_quit" "en"
bMotion_plugin_add_irc_event "default part" "part" ".*" 15 "bMotion_plugins_irc_default_quit" "en"

bMotion_abstract_register "departs-nice"
bMotion_abstract_batchadd "departs-nice" [list "bye %%" "i like them %VAR{smiles}" "i wish they didn't have to go %VAR{unsmiles}" "mmm %%"]

bMotion_abstract_register "departs-nasty"
bMotion_abstract_batchadd "departs-nasty" [list "bye sucker" "i don't like them" "i hope they don't come back" "%%: AND DON'T COME BACK!" "See You Next Tuesday, %%!" "%%: don't let the door hit your ass on the way out%|because I don't want ass-prints on my new door!"]
