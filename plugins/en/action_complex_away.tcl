## bMotion plugin: away handler
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "away" "^(is )?away" 40 bMotion_plugin_complex_action_away "en"
bMotion_plugin_add_action_complex "back" "^((is )?back)|(has returned)" 40 bMotion_plugin_complex_action_back "en"

# abstracts
set goodnights {
  "night"
  "nn"
  "night %%"
  "sleep well"
  "goodnight :)"
  "night :)"
  "g'night"
  "sleep well %%"
  "nn %%"
  "don't have really bad dreams about a nasty man coming to strangle you in your bed"
}

set cyas {
  "l8r"
  "l8r"
  "cya"
  "cya"
  "cya l8r"
  "cya l8r"
  "bye"
  "byebye"
  "/waves"
  "you still here?"
  "quand vous retournez, apporter les tartes!"
}

set welcomeBacks {
  "re"
  "wb"
  "welcome back"
  "welcome back"
  "hey"
  "hi"
  "bllblblbl"
  "pop"
  "they're back. I'm so happy!"
}

set joinins {
  "~rarr~"
  "~oof~"
  "ooh, can I come?"
  "can I join in?"
  "wahey-waterproof"
  ":)"
  "have fun ~rarr~"
}

set goodMornings {
  "Morning %%"
  "good morning %%"
}

set autoAways {
  "oh, so we're not interesting enough?%|%bot[50,obviously not]"
  "o, bye then"
  "bored? fine, we'll have fun without you ;)"
  "bored? fine, we'll have fun without you ;)%|%bot[50,¬VAR{rarrs}]"
  "fine, leave your computer, see if i care"
  "damnit! I WAS TALKING TO YOU!"
  "%%"
  "yea, go away, you don't care"
  "auto away my arse"
  "Great! Time to talk behind your back!%|So what do you guys really think about %%"
}

set awayWorks {
  "hf %%"
  "have fun %%"
  "have a nice day %% :)"
}

set goodlucks {
  "GL"
  "good luck :)"
  "good luck"
}


proc bMotion_plugin_complex_action_away { nick host handle channel text } {

  #elections!
  if {![bMotion_interbot_me_next $channel]} { return 0 }
  
  #check we haven't already done something for this nick
  if {$nick == [bMotion_plugins_settings_get "complex:away" "lastnick" $channel ""]} {
    return 1
  }

  if {![bMotion_interbot_me_next $channel]} {
    return 1
  }

  #save as newnick because if they do a /me next it'll be their new nick
  bMotion_plugins_settings_set "complex:away" "lastnick" $channel "" $nick
  
  #autoaway
  if [regexp -nocase "(auto( |-)?away|idle)" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{autoAways}"
    return 1
  }

  #work
  if [regexp -nocase "w(o|0|e|3)rk" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{awayWorks}"
    return 1
  }

  #sleep
  if [regexp -nocase "(sleep|regenerating|bed|zzz)" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{goodnights}"
    if [bMotionLike $nick $host] {
      if [rand 2] {return 1}
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "*hugs*"
    }
    return 1
  }

  #shower
  if [regexp -nocase "(shower|nekkid)" $text] {
    if [bMotionLike $nick $host] {
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{joinins}"
      bMotionGetHorny
      return 1
    }
  }

  #exam
  if [regexp -nocase "exam" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{goodlucks}"
    return 1
  }
    
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{cyas}"
  return 1
}

proc bMotion_plugin_complex_action_back { nick host handle channel text } {

  if {![bMotion_interbot_me_next $channel]} { return 0 }

  #check we haven't already done something for this nick
  if {$nick == [bMotion_plugins_settings_get "complex:returned" "lastnick" $channel ""]} {
    return 1
  }

  if {![bMotion_interbot_me_next $channel]} {
    return 1
  }

  #save as newnick because if they do a /me next it'll be their new nick
  bMotion_plugins_settings_set "complex:returned" "lastnick" $channel "" $nick

  #let's do some cool stuff
  #if they came back from sleep, it's morning
  if [regexp -nocase "(sleep|regenerating|bed|zzz)" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{goodMornings}"
    return 1
  }

  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{welcomeBacks}"
  }
  set bMotionCache(lastGreeted) $nick
  return 0
}

